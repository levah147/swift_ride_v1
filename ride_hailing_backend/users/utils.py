from rest_framework.views import exception_handler
from rest_framework.response import Response


def custom_exception_handler(exc, context):
    """
    Custom exception handler that returns responses in a consistent format.
    """
    response = exception_handler(exc, context)
    
    if response is not None:
        # Format the response data
        response_data = {
            'status': 'error',
            'message': 'An error occurred',
            'errors': response.data
        }
        
        # Use more specific error message based on status code
        if response.status_code == 400:
            response_data['message'] = 'Invalid input'
        elif response.status_code == 401:
            response_data['message'] = 'Authentication failed'
        elif response.status_code == 403:
            response_data['message'] = 'Permission denied'
        elif response.status_code == 404:
            response_data['message'] = 'Resource not found'
        elif response.status_code == 405:
            response_data['message'] = 'Method not allowed'
        elif response.status_code >= 500:
            response_data['message'] = 'Server error'
        
        response.data = response_data
    
    return response
