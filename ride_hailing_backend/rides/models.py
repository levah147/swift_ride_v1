from django.db import models
from django.utils.translation import gettext_lazy as _
import uuid
from users.models import User, UserLocation, PaymentMethod


class Driver(models.Model):
    """Model representing a driver in the ride-hailing system"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='driver_profile')
    vehicle_make = models.CharField(max_length=50)
    vehicle_model = models.CharField(max_length=50)
    vehicle_year = models.IntegerField()
    vehicle_color = models.CharField(max_length=30)
    vehicle_license_plate = models.CharField(max_length=20)
    driving_license_number = models.CharField(max_length=50)
    is_active = models.BooleanField(default=True)
    is_available = models.BooleanField(default=False)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    total_rides = models.IntegerField(default=0)
    current_latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    current_longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    last_location_update = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.full_name} - {self.vehicle_make} {self.vehicle_model}"


class RideCategory(models.Model):
    """Model representing different ride categories (standard, comfort, XL, etc.)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=50)
    description = models.TextField()
    base_fare = models.DecimalField(max_digits=10, decimal_places=2)
    per_km_rate = models.DecimalField(max_digits=10, decimal_places=2)
    per_minute_rate = models.DecimalField(max_digits=10, decimal_places=2)
    capacity = models.IntegerField(default=4)
    image = models.ImageField(upload_to='ride_categories/', null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name = _('ride category')
        verbose_name_plural = _('ride categories')


class Ride(models.Model):
    """Model representing a ride in the system"""
    STATUS_CHOICES = (
        ('requested', 'Requested'),
        ('accepted', 'Accepted'),
        ('arrived', 'Driver Arrived'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    )
    
    PAYMENT_STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='rides')
    driver = models.ForeignKey(Driver, on_delete=models.SET_NULL, null=True, blank=True, related_name='rides')
    category = models.ForeignKey(RideCategory, on_delete=models.CASCADE, related_name='rides')
    
    # Pickup and destination details
    pickup_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    pickup_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    pickup_address = models.CharField(max_length=255)
    destination_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    destination_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    destination_address = models.CharField(max_length=255)
    
    # Distance and duration estimates
    estimated_distance_km = models.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration_minutes = models.IntegerField()
    actual_distance_km = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    actual_duration_minutes = models.IntegerField(null=True, blank=True)
    
    # Ride status
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='requested')
    
    # Payment details
    payment_method = models.ForeignKey(PaymentMethod, on_delete=models.SET_NULL, null=True, blank=True)
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    base_fare = models.DecimalField(max_digits=10, decimal_places=2)
    distance_fare = models.DecimalField(max_digits=10, decimal_places=2)
    time_fare = models.DecimalField(max_digits=10, decimal_places=2)
    surge_multiplier = models.DecimalField(max_digits=5, decimal_places=2, default=1.0)
    total_fare = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Timestamps
    requested_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    driver_arrived_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    
    # Cancellation details
    cancelled_by = models.CharField(max_length=10, choices=[('user', 'User'), ('driver', 'Driver'), ('system', 'System')], null=True, blank=True)
    cancellation_reason = models.TextField(null=True, blank=True)
    
    # Rating and feedback
    user_rating = models.IntegerField(null=True, blank=True)
    user_feedback = models.TextField(null=True, blank=True)
    driver_rating = models.IntegerField(null=True, blank=True)
    driver_feedback = models.TextField(null=True, blank=True)
    
    class Meta:
        ordering = ['-requested_at']
    
    def __str__(self):
        return f"Ride {self.id} - {self.status}"


class RideLocation(models.Model):
    """Model to store ride location updates during the journey"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ride = models.ForeignKey(Ride, on_delete=models.CASCADE, related_name='location_updates')
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['timestamp']
    
    def __str__(self):
        return f"Location update for ride {self.ride.id} at {self.timestamp}"
