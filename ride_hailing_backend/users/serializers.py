from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.contrib.auth import authenticate
from django.utils.translation import gettext_lazy as _
from .models import User, UserLocation, PaymentMethod
import re


class UserLocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserLocation
        fields = ['id', 'name', 'address', 'latitude', 'longitude', 'type', 'is_favorite']
        read_only_fields = ['id']
        

class PaymentMethodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentMethod
        fields = [
            'id', 'type', 'is_default', 'card_last_four', 
            'card_brand', 'wallet_provider', 'wallet_number'
        ]
        read_only_fields = ['id']
        
    def validate(self, data):
        if data.get('type') == 'card':
            if not data.get('card_last_four') or not data.get('card_brand'):
                raise serializers.ValidationError({
                    "card_details": "Card last four digits and brand are required for card payment method"
                })
        elif data.get('type') == 'wallet':
            if not data.get('wallet_provider') or not data.get('wallet_number'):
                raise serializers.ValidationError({
                    "wallet_details": "Wallet provider and number are required for wallet payment method"
                })
        return data


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    confirm_password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    
    class Meta:
        model = User
        fields = ['id', 'email', 'phone_number', 'full_name', 'password', 'confirm_password']
        read_only_fields = ['id']
        
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("User with this email already exists.")
        return value
        
    def validate_phone_number(self, value):
        # Basic phone number validation (can be enhanced for specific country formats)
        if not re.match(r'^\+?[0-9]{10,15}$', value):
            raise serializers.ValidationError("Enter a valid phone number (10-15 digits with optional + prefix).")
        
        if User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError("User with this phone number already exists.")
        return value
    
    def validate_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value
        
    def validate(self, data):
        if data.get('password') != data.get('confirm_password'):
            raise serializers.ValidationError({"confirm_password": "Password fields don't match."})
        return data
        
    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = User.objects.create_user(**validated_data)
        return user


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=False)
    phone_number = serializers.CharField(required=False)
    password = serializers.CharField(style={'input_type': 'password'})
    
    def validate(self, data):
        # Require either email or phone_number
        if not data.get('email') and not data.get('phone_number'):
            raise serializers.ValidationError(
                {"login_id": "Either email or phone number is required."}
            )
            
        # Check which field to use for authentication
        if data.get('email'):
            try:
                user = User.objects.get(email=data.get('email'))
            except User.DoesNotExist:
                raise serializers.ValidationError(
                    {"email": "No user found with this email address."}
                )
        else:
            try:
                user = User.objects.get(phone_number=data.get('phone_number'))
            except User.DoesNotExist:
                raise serializers.ValidationError(
                    {"phone_number": "No user found with this phone number."}
                )
        
        # Authenticate user
        user = authenticate(
            username=user.email,  # Django uses the USERNAME_FIELD which is email
            password=data.get('password')
        )
        
        if not user:
            raise serializers.ValidationError(
                {"password": "Invalid password."}
            )
            
        if not user.is_active:
            raise serializers.ValidationError(
                {"non_field_errors": "User account is disabled."}
            )
            
        # Store user in the serializer context for the view to use
        self.context['user'] = user
        return data


class UserProfileSerializer(serializers.ModelSerializer):
    saved_locations = UserLocationSerializer(many=True, read_only=True)
    payment_methods = PaymentMethodSerializer(many=True, read_only=True)
    total_rides = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'phone_number', 'full_name', 'profile_image',
            'is_verified', 'date_joined', 'saved_locations', 'payment_methods',
            'total_rides'
        ]
        read_only_fields = ['id', 'is_verified', 'date_joined', 'total_rides']
        
    def get_total_rides(self, obj):
        # Count user's rides (assuming there's a Ride model with user foreign key)
        return obj.rides.count() if hasattr(obj, 'rides') else 0


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True, style={'input_type': 'password'})
    new_password = serializers.CharField(required=True, style={'input_type': 'password'})
    confirm_password = serializers.CharField(required=True, style={'input_type': 'password'})
    
    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Current password is incorrect.")
        return value
        
    def validate_new_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value
        
    def validate(self, data):
        if data.get('new_password') != data.get('confirm_password'):
            raise serializers.ValidationError({"confirm_password": "Password fields don't match."})
        if data.get('old_password') == data.get('new_password'):
            raise serializers.ValidationError({"new_password": "New password must be different from the current password."})
        return data
