---
name: django
description: Django coding rules. Always use when working with Django, including editing, reviewing, or writing Django models, migrations, ORM queries, forms, views, or serializers.
---

# Django

- Do not write Django migrations manually (e.g. using the Write tool). Always use Django's CLI to generate migrations instead.
- Never make database operations (obj.save, Model.objects.whatever, etc.) inside loops.
- Don't create constants to use in `model_to_dict` fields, unless same fields are used multiple times.
    Good:
    ```python
    payload = model_to_dict(user, fields=["id", "email", "first_name"])
    ```

    Bad:
    ```python
    USER_FIELDS = ["id", "email", "first_name"]
    payload = model_to_dict(user, fields=USER_FIELDS)
    ```

    Good when reused:
    ```python
    USER_FIELDS = ["id", "email", "first_name"]

    payload = model_to_dict(user, fields=USER_FIELDS)
    audit_payload = model_to_dict(other_user, fields=USER_FIELDS)
    ```
