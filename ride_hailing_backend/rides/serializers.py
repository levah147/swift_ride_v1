from rest_framework import serializers
from django.db.models import Avg
from .models import Driver, RideCategory, Ride, RideLocation
from users.serializers import UserProfileSerializer, PaymentMethodSerializer, UserLocationSerializer


class DriverSerializer(serializers.ModelSerializer):
    user = UserProfileSerializer(read_only=True)
    rating = serializers.DecimalField(max_digits=3, decimal_places=2, read_only=True)
    
    class Meta:
        model = Driver
        fields = [
            'id', 'user', 'vehicle_make', 'vehicle_model', 'vehicle_year',
            'vehicle_color', 'vehicle_license_plate', 'is_available',
            'rating', 'total_rides', 'current_latitude', 'current_longitude'
        ]
        read_only_fields = ['id', 'rating', 'total_rides']


class RideCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = RideCategory
        fields = '__all__'


class RideLocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = RideLocation
        fields = ['id', 'latitude', 'longitude', 'timestamp']
        read_only_fields = ['id', 'timestamp']


class RideSerializer(serializers.ModelSerializer):
    user = UserProfileSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    category = RideCategorySerializer(read_only=True)
    payment_method = PaymentMethodSerializer(read_only=True)
    location_updates = RideLocationSerializer(many=True, read_only=True)
    
    class Meta:
        model = Ride
        fields = '__all__'
        read_only_fields = [
            'id', 'user', 'driver', 'status', 'accepted_at', 'driver_arrived_at',
            'started_at', 'completed_at', 'cancelled_at', 'cancelled_by',
            'actual_distance_km', 'actual_duration_minutes', 'payment_status'
        ]


class RideRequestSerializer(serializers.ModelSerializer):
    category_id = serializers.UUIDField(write_only=True)
    payment_method_id = serializers.UUIDField(write_only=True, required=False)
    
    class Meta:
        model = Ride
        fields = [
            'category_id', 'payment_method_id',
            'pickup_latitude', 'pickup_longitude', 'pickup_address',
            'destination_latitude', 'destination_longitude', 'destination_address',
            'estimated_distance_km', 'estimated_duration_minutes'
        ]
    
    def create(self, validated_data):
        user = self.context['request'].user
        category_id = validated_data.pop('category_id')
        payment_method_id = validated_data.pop('payment_method_id', None)
        
        # Get ride category
        try:
            category = RideCategory.objects.get(id=category_id)
        except RideCategory.DoesNotExist:
            raise serializers.ValidationError({"category_id": "Invalid ride category"})
        
        # Calculate fare
        base_fare = category.base_fare
        distance_fare = category.per_km_rate * validated_data['estimated_distance_km']
        time_fare = category.per_minute_rate * validated_data['estimated_duration_minutes']
        
        # TODO: Implement surge pricing logic if needed
        surge_multiplier = 1.0
        
        total_fare = (base_fare + distance_fare + time_fare) * surge_multiplier
        
        # Get payment method if provided, otherwise use default
        payment_method = None
        if payment_method_id:
            payment_method = user.payment_methods.filter(id=payment_method_id).first()
            if not payment_method:
                raise serializers.ValidationError({"payment_method_id": "Invalid payment method"})
        else:
            # Get default payment method
            payment_method = user.payment_methods.filter(is_default=True).first()
        
        # Create the ride
        ride = Ride.objects.create(
            user=user,
            category=category,
            payment_method=payment_method,
            base_fare=base_fare,
            distance_fare=distance_fare,
            time_fare=time_fare,
            surge_multiplier=surge_multiplier,
            total_fare=total_fare,
            **validated_data
        )
        
        return ride


class RideFeedbackSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ride
        fields = ['user_rating', 'user_feedback']
    
    def validate_user_rating(self, value):
        if value is not None and (value < 1 or value > 5):
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value


class HomePageDataSerializer(serializers.Serializer):
    """Serializer for home page data"""
    user = UserProfileSerializer()
    saved_locations = UserLocationSerializer(many=True)
    nearby_drivers_count = serializers.IntegerField()
    categories = RideCategorySerializer(many=True)
    recent_rides = RideSerializer(many=True)
    promotions = serializers.ListField(child=serializers.DictField())
