from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
import uuid


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_('Users must have an email address'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(_('email address'), unique=True)
    phone_number = models.CharField(max_length=20, unique=True)
    full_name = models.CharField(max_length=255)
    
    profile_image = models.ImageField(upload_to='profile_images/', null=True, blank=True)
    
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    
    date_joined = models.DateTimeField(default=timezone.now)
    last_login = models.DateTimeField(null=True, blank=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['phone_number', 'full_name']
    
    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
    
    def __str__(self):
        return self.email
    
    def get_full_name(self):
        return self.full_name


class UserLocation(models.Model):
    LOCATION_TYPES = (
        ('home', 'Home'),
        ('work', 'Work'),
        ('other', 'Other'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='saved_locations')
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    type = models.CharField(max_length=20, choices=LOCATION_TYPES, default='other')
    is_favorite = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = _('user location')
        verbose_name_plural = _('user locations')
        ordering = ['-is_favorite', 'name']
    
    def __str__(self):
        return f"{self.user.full_name}'s {self.name}"


class PaymentMethod(models.Model):
    PAYMENT_TYPES = (
        ('card', 'Credit/Debit Card'),
        ('cash', 'Cash'),
        ('wallet', 'Mobile Wallet'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payment_methods')
    type = models.CharField(max_length=20, choices=PAYMENT_TYPES)
    is_default = models.BooleanField(default=False)
    
    # Card specific fields (optional, only used for card type)
    card_last_four = models.CharField(max_length=4, null=True, blank=True)
    card_expiry_month = models.CharField(max_length=2, null=True, blank=True)
    card_expiry_year = models.CharField(max_length=2, null=True, blank=True)
    card_brand = models.CharField(max_length=20, null=True, blank=True)
    
    # Mobile wallet fields (optional, only used for wallet type)
    wallet_provider = models.CharField(max_length=50, null=True, blank=True)
    wallet_number = models.CharField(max_length=20, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = _('payment method')
        verbose_name_plural = _('payment methods')
        ordering = ['-is_default', 'type']
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'type', 'card_last_four'], 
                name='unique_card_for_user',
                condition=models.Q(type='card')
            ),
            models.UniqueConstraint(
                fields=['user', 'type', 'wallet_number'], 
                name='unique_wallet_for_user',
                condition=models.Q(type='wallet')
            )
        ]
    
    def __str__(self):
        if self.type == 'card':
            return f"{self.card_brand} **** {self.card_last_four}"
        elif self.type == 'wallet':
            return f"{self.wallet_provider} - {self.wallet_number}"
        return "Cash"
