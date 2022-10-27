{%- set exclude_labels=[
    'send_to_telegram',
    'kubernetes_name',
    'kubernetes_namespace',
    'kubernetes_node',
    'role',
    'job',
    'instance',
    'app',
    'app_kubernetes_io_managed_by',
    'app_kubernetes_io_instance',
    'app_kubernetes_io_name',
    'helm_sh_chart',
    'alertname',
    'severity',
    ]
-%}
{% for alert in data['alerts'] %}
{% if data['status']=='firing' %}🔥{% else %}✅{% endif %} {{ alert['annotations']['description'] }}
{%- if alert['annotations']['summary'] %}
{{ alert['annotations']['summary'] -}}
{% endif %}
{%- for key, value in alert['labels'] | dictsort %}
{%- if key not in exclude_labels %}
*{{ key }}:* `{{ value }}`
{%- endif -%}
{% endfor %}
{% endfor %}
