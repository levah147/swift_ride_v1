from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, PaymentMethod


@receiver(post_save, sender=User)
def create_default_payment_method(sender, instance, created, **kwargs):
    """
    Create a default cash payment method for new users.
    """
    if created:
        PaymentMethod.objects.create(
            user=instance,
            type='cash',
            is_default=True
        )
