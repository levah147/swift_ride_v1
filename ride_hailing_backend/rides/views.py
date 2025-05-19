from rest_framework import viewsets, status, generics, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db.models import Q
from django.utils import timezone
from datetime import timedelta
from .models import Driver, RideCategory, Ride, RideLocation
from .serializers import (
    DriverSerializer,
    RideCategorySerializer,
    RideSerializer,
    RideRequestSerializer,
    RideFeedbackSerializer,
    RideLocationSerializer,
    HomePageDataSerializer
)


class RideCategoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for retrieving ride categories.
    """
    queryset = RideCategory.objects.filter(is_active=True)
    serializer_class = RideCategorySerializer
    permission_classes = [permissions.IsAuthenticated]


class RideViewSet(viewsets.ModelViewSet):
    """
    API endpoint for ride-related operations.
    """
    serializer_class = RideSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Ride.objects.filter(user=self.request.user).order_by('-requested_at')
    
    def get_serializer_class(self):
        if self.action == 'create':
            return RideRequestSerializer
        elif self.action == 'rate_ride':
            return RideFeedbackSerializer
        return self.serializer_class
    
    def create(self, request, *args, **kwargs):
        """
        Request a new ride.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        ride = serializer.save()
        
        return Response({
            'status': 'success',
            'message': 'Ride requested successfully',
            'data': RideSerializer(ride).data
        }, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """
        Cancel a ride.
        """
        ride = self.get_object()
        
        # Check if ride can be cancelled
        if ride.status not in ['requested', 'accepted']:
            return Response({
                'status': 'error',
                'message': 'This ride cannot be cancelled',
                'errors': {'status': f'Ride is already {ride.status}'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Update ride status
        ride.status = 'cancelled'
        ride.cancelled_at = timezone.now()
        ride.cancelled_by = 'user'
        ride.cancellation_reason = request.data.get('reason', 'Cancelled by user')
        ride.save()
        
        return Response({
            'status': 'success',
            'message': 'Ride cancelled successfully',
            'data': RideSerializer(ride).data
        })
    
    @action(detail=True, methods=['post'])
    def rate_ride(self, request, pk=None):
        """
        Rate a completed ride.
        """
        ride = self.get_object()
        
        # Check if ride is completed
        if ride.status != 'completed':
            return Response({
                'status': 'error',
                'message': 'Only completed rides can be rated',
                'errors': {'status': f'Ride status is {ride.status}'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if ride is already rated
        if ride.user_rating is not None:
            return Response({
                'status': 'error',
                'message': 'This ride has already been rated',
                'errors': {'user_rating': 'Ride is already rated'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = self.get_serializer(ride, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        updated_ride = serializer.save()
        
        # Update driver rating
        if updated_ride.driver and updated_ride.user_rating:
            driver = updated_ride.driver
            # Calculate average rating
            avg_rating = Ride.objects.filter(
                driver=driver,
                user_rating__isnull=False
            ).aggregate(avg=Avg('user_rating'))['avg'] or 0
            
            driver.rating = avg_rating
            driver.save(update_fields=['rating'])
        
        return Response({
            'status': 'success',
            'message': 'Ride rated successfully',
            'data': RideSerializer(updated_ride).data
        })
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        """
        Get the user's active ride (if any).
        """
        active_ride = Ride.objects.filter(
            user=request.user,
            status__in=['requested', 'accepted', 'arrived', 'in_progress']
        ).first()
        
        if not active_ride:
            return Response({
                'status': 'success',
                'message': 'No active ride found',
                'data': None
            })
        
        return Response({
            'status': 'success',
            'message': 'Active ride retrieved successfully',
            'data': RideSerializer(active_ride).data
        })
    
    @action(detail=False, methods=['get'])
    def history(self, request):
        """
        Get the user's ride history with optional filtering.
        """
        status_filter = request.query_params.get('status')
        date_from = request.query_params.get('date_from')
        date_to = request.query_params.get('date_to')
        
        queryset = self.get_queryset()
        
        # Apply filters
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        if date_from:
            queryset = queryset.filter(requested_at__gte=date_from)
        
        if date_to:
            queryset = queryset.filter(requested_at__lte=date_to)
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'status': 'success',
            'message': 'Ride history retrieved successfully',
            'data': serializer.data
        })


class RideLocationUpdateView(generics.CreateAPIView):
    """
    API endpoint to create ride location updates.
    This would typically be used by the driver app to send location updates.
    """
    serializer_class = RideLocationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def create(self, request, *args, **kwargs):
        # Ensure ride_id is provided
        ride_id = request.data.get('ride_id')
        if not ride_id:
            return Response({
                'status': 'error',
                'message': 'Ride ID is required',
                'errors': {'ride_id': 'This field is required'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Check if this is a valid active ride
            ride = Ride.objects.get(
                Q(id=ride_id),
                Q(status__in=['accepted', 'arrived', 'in_progress']),
                Q(driver__user=request.user)  # Ensure driver is the one updating
            )
        except Ride.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Invalid or inactive ride',
                'errors': {'ride_id': 'No active ride found with this ID'}
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create location update
        serializer = self.get_serializer(data={
            'ride': ride.id,
            'latitude': request.data.get('latitude'),
            'longitude': request.data.get('longitude')
        })
        serializer.is_valid(raise_exception=True)
        location_update = serializer.save(ride=ride)
        
        # Update driver's current location
        driver = ride.driver
        driver.current_latitude = request.data.get('latitude')
        driver.current_longitude = request.data.get('longitude')
        driver.last_location_update = timezone.now()
        driver.save(update_fields=['current_latitude', 'current_longitude', 'last_location_update'])
        
        return Response({
            'status': 'success',
            'message': 'Location updated successfully',
            'data': serializer.data
        }, status=status.HTTP_201_CREATED)


class HomePageDataView(generics.GenericAPIView):
    """
    API endpoint to get all data needed for the home page.
    """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = HomePageDataSerializer
    
    def get(self, request, *args, **kwargs):
        user = request.user
        
        # Get user's saved locations
        saved_locations = user.saved_locations.all()
        
        # Count nearby drivers (within 5km of user's last known location)
        # This is a simplified implementation - in a real app you'd use geospatial queries
        nearby_drivers_count = 0
        if saved_locations.filter(is_favorite=True, type='home').exists():
            home = saved_locations.get(is_favorite=True, type='home')
            # Count drivers who have updated their location in the last 15 minutes
            # This is a simplified implementation
            nearby_drivers_count = Driver.objects.filter(
                is_active=True,
                is_available=True,
                last_location_update__gte=timezone.now() - timedelta(minutes=15)
            ).count()
        
        # Get ride categories
        categories = RideCategory.objects.filter(is_active=True)
        
        # Get user's recent rides (last 3)
        recent_rides = Ride.objects.filter(user=user).order_by('-requested_at')[:3]
        
        # Example promotions (would come from a real promotions system)
        promotions = [
            {
                'id': '1',
                'title': '20% Off Your Next Ride',
                'description': 'Use code WELCOME20 for 20% off your next ride',
                'code': 'WELCOME20',
                'expires_at': (timezone.now() + timedelta(days=7)).isoformat(),
                'image_url': 'https://example.com/promotions/welcome20.jpg'
            },
            {
                'id': '2',
                'title': 'Refer a Friend',
                'description': 'Refer a friend and you both get free rides',
                'code': 'REFER10',
                'expires_at': (timezone.now() + timedelta(days=30)).isoformat(),
                'image_url': 'https://example.com/promotions/refer.jpg'
            }
        ]
        
        # Assemble data for home page
        data = {
            'user': user,
            'saved_locations': saved_locations,
            'nearby_drivers_count': nearby_drivers_count,
            'categories': categories,
            'recent_rides': recent_rides,
            'promotions': promotions
        }
        
        serializer = self.get_serializer(data)
        
        return Response({
            'status': 'success',
            'message': 'Home page data retrieved successfully',
            'data': serializer.data
        })
