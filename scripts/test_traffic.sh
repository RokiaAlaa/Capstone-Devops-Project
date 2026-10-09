kubectl run load-generator -n prod --image=curlimages/curl --restart=Never --command -- sh -c '
for i in $(seq 1 30); do
  curl -s -o /dev/null -w "user: %{http_code}\n"    http://user-service:8000/api/users/
  curl -s -o /dev/null -w "product: %{http_code}\n" http://product-service:8000/api/products/
  curl -s -o /dev/null -w "order: %{http_code}\n"   http://order-service:8000/api/orders/
  sleep 1
done'