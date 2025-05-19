from django.contrib import admin
from .models import Driver, RideCategory, Ride, RideLocation


@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ('user', 'vehicle_make', 'vehicle_model', 'is_active', 'is_available', 'rating')
    list_filter = ('is_active', 'is_available')
    search_fields = ('user__email', 'user__full_name', 'vehicle_license_plate')


@admin.register(RideCategory)
class RideCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'base_fare', 'per_km_rate', 'capacity', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name', 'description')


class RideLocationInline(admin.TabularInline):
    model = RideLocation
    extra = 0
    readonly_fields = ('timestamp',)


@admin.register(Ride)
class RideAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'driver', 'status', 'total_fare', 'requested_at')
    list_filter = ('status', 'payment_status', 'requested_at')
    search_fields = ('user__email', 'driver__user__email', 'pickup_address', 'destination_address')
    readonly_fields = (
        'id', 'user', 'driver', 'requested_at', 'accepted_at', 'driver_arrived_at',
        'started_at', 'completed_at', 'cancelled_at'
    )
    inlines = [RideLocationInline]
    fieldsets = (
        ('Basic Info', {
            'fields': ('id', 'user', 'driver', 'category', 'status')
        }),
        ('Locations', {
            'fields': (
                'pickup_address', 'pickup_latitude', 'pickup_longitude',
                'destination_address', 'destination_latitude', 'destination_longitude'
            )
        }),
        ('Ride Details', {
            'fields': (
                'estimated_distance_km', 'estimated_duration_minutes',
                'actual_distance_km', 'actual_duration_minutes'
            )
        }),
        ('Payment', {
            'fields': (
                'payment_method', 'payment_status', 'base_fare',
                'distance_fare', 'time_fare', 'surge_multiplier', 'total_fare'
            )
        }),
        ('Timestamps', {
            'fields': (
                'requested_at', 'accepted_at', 'driver_arrived_at',
                'started_at', 'completed_at', 'cancelled_at'
            )
        }),
        ('Cancellation', {
            'fields': ('cancelled_by', 'cancellation_reason'),
            'classes': ('collapse',)
        }),
        ('Ratings', {
            'fields': ('user_rating', 'user_feedback', 'driver_rating', 'driver_feedback'),
            'classes': ('collapse',)
        }),
    )


@admin.register(RideLocation)
class RideLocationAdmin(admin.ModelAdmin):
    list_display = ('ride', 'latitude', 'longitude', 'timestamp')
    list_filter = ('timestamp',)
    search_fields = ('ride__id',)
