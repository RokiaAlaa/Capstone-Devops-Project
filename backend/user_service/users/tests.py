import pytest
from rest_framework.test import APIClient
from .models import User

@pytest.mark.django_db
class TestUserAPI:
    def setup_method(self):
        self.client = APIClient()

    def test_create_user(self):
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
        }
        response = self.client.post('/api/users/', data)
        assert response.status_code == 201
        assert 'password' not in response.data

    def test_create_user_hashes_password(self):
        data = {
            'username': 'testuser2',
            'email': 'test2@example.com',
            'password': 'testpass123',
        }
        self.client.post('/api/users/', data)
        user = User.objects.get(username='testuser2')
        assert user.password != 'testpass123'
        assert user.check_password('testpass123')

    def test_get_users(self):
        User.objects.create_user(
            username='user1', email='user1@example.com', password='pass123'
        )
        response = self.client.get('/api/users/')
        assert response.status_code == 200
        assert len(response.data) == 1

    def test_update_user(self):
        user = User.objects.create_user(
            username='user1', email='user1@example.com', password='pass123'
        )
        response = self.client.patch(f'/api/users/{user.id}/', {'phone': '012345689'})
        assert response.status_code == 200
        assert response.data['phone'] == '012345689'

    def test_delete_user(self):
        user = User.objects.create_user(
            username='user1', email='user1@example.com', password='pass123'
        )
        response = self.client.delete(f'/api/users/{user.id}/')
        assert response.status_code == 204
        assert User.objects.count() == 0