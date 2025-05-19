from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User, UserLocation, PaymentMethod


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'phone_number', 'full_name', 'is_active', 'is_staff', 'is_verified')
    list_filter = ('is_active', 'is_staff', 'is_verified', 'date_joined')
    search_fields = ('email', 'phone_number', 'full_name')
    ordering = ('-date_joined',)
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {'fields': ('full_name', 'phone_number', 'profile_image')}),
        (_('Permissions'), {'fields': ('is_active', 'is_verified', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'phone_number', 'full_name', 'password1', 'password2'),
        }),
    )


@admin.register(UserLocation)
class UserLocationAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'type', 'is_favorite')
    list_filter = ('type', 'is_favorite')
    search_fields = ('name', 'address', 'user__email', 'user__full_name')


@admin.register(PaymentMethod)
class PaymentMethodAdmin(admin.ModelAdmin):
    list_display = ('user', 'type', 'is_default', 'get_payment_details')
    list_filter = ('type', 'is_default')
    search_fields = ('user__email', 'card_last_four', 'wallet_number')
    
    def get_payment_details(self, obj):
        if obj.type == 'card':
            return f"{obj.card_brand} **** {obj.card_last_four}"
        elif obj.type == 'wallet':
            return f"{obj.wallet_provider} - {obj.wallet_number}"
        return "Cash"
    
    get_payment_details.short_description = 'Payment Details'
