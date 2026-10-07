import pytest
from rest_framework.test import APIClient
from .models import Product

@pytest.mark.django_db
class TestProductAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_create_product(self):
        data = {
            'name': 'Laptop',
            'description': 'A fast laptop',
            'price': '1500.00',
            'stock': 10,
        }
        response = self.client.post('/api/products/', data)
        assert response.status_code == 201
        assert response.data['name'] == 'Laptop'

    def test_get_products(self):
        Product.objects.create(
            name='Phone', description='A phone', price=500, stock=5
        )
        response = self.client.get('/api/products/')
        assert response.status_code == 200
        assert len(response.data) == 1

    def test_update_product_stock(self):
        product = Product.objects.create(
            name='Tablet', description='A tablet', price=300, stock=20
        )
        response = self.client.patch(f'/api/products/{product.id}/', {'stock': 15})
        assert response.status_code == 200
        assert response.data['stock'] == 15

    def test_delete_product(self):
        product = Product.objects.create(
            name='Mouse', description='A mouse', price=20, stock=50
        )
        response = self.client.delete(f'/api/products/{product.id}/')
        assert response.status_code == 204
        assert Product.objects.count() == 0