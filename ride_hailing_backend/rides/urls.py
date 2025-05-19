from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RideCategoryViewSet,
    RideViewSet,
    RideLocationUpdateView,
    HomePageDataView
)

router = DefaultRouter()
router.register(r'categories', RideCategoryViewSet)
router.register(r'rides', RideViewSet, basename='ride')

urlpatterns = [
    path('', include(router.urls)),
    path('location-update/', RideLocationUpdateView.as_view(), name='location-update'),
    path('home/', HomePageDataView.as_view(), name='home-data'),
]
