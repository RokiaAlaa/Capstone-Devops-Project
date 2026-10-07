import pytest
from rest_framework.test import APIClient
from .models import Order

@pytest.mark.django_db
class TestOrderAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_create_order(self):
        data = {
            'user_id': 1,
            'products': [{'product_id': 1, 'quantity': 2}],
            'total': '3000.00',
            'status': 'pending',
        }
        response = self.client.post('/api/orders/', data, format='json')
        assert response.status_code == 201
        assert response.data['status'] == 'pending'

    def test_get_orders(self):
        Order.objects.create(user_id=1, products=[{'product_id': 1, 'quantity': 1}], total=500)

        response = self.client.get('/api/orders/')
        assert response.status_code == 200
        assert len(response.data['results']) == 1
        
    def test_update_order_status(self):
        order = Order.objects.create(user_id=1, products=[{'product_id': 1, 'quantity': 1}], total=500)

        response = self.client.patch(f'/api/orders/{order.id}/', {'status': 'shipped'})
        assert response.status_code == 200
        assert response.data['status'] == 'shipped'

    def test_delete_order(self):
        order = Order.objects.create(user_id=1, products=[{'product_id': 1, 'quantity': 1}], total=500)

        response = self.client.delete(f'/api/orders/{order.id}/')
        assert response.status_code == 204
        assert Order.objects.count() == 0