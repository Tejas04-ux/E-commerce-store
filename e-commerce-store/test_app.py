from app import app


def get(path, method="get"):
    client = app.test_client()
    return getattr(client, method)(path)


def test_home_returns_200():
    response = get('/')
    assert response.status_code == 200


def test_home_renders_store_page():
    response = get('/')
    assert response.content_type.startswith('text/html')
    assert b'Nova' in response.data


def test_health_returns_ok():
    response = get('/health')
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_unknown_page_returns_404():
    response = get('/this-page-does-not-exist')
    assert response.status_code == 404


def test_wrong_method_returns_405():
    response = get('/health', method='post')
    assert response.status_code == 405


def test_metrics_endpoint_exposes_prometheus_format():
    get('/health')  # generate at least one sample
    response = get('/metrics')
    assert response.status_code == 200
    assert response.content_type.startswith('text/plain')
    body = response.data.decode()
    assert 'http_requests_total' in body
    assert 'http_request_duration_seconds' in body


def test_metrics_endpoint_does_not_count_itself():
    get('/metrics')
    body = get('/metrics').data.decode()
    assert 'endpoint="/metrics"' not in body
