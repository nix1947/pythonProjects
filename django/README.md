- [Creating custom user with account app.](#creating-custom-user-with-account-app)

## Creating custom user with account app. 

```bash 
mkdir apps 
mkdir apps/account 

python manage.py createapp account apps/account
```

**Register in settings.py**
```python 
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "apps.accounts",  # new
]
```

**Overriding auth user model**
```python
AUTH_USER_MODEL='account.User'
```

*Set this before creating any migrations for the first time** 

**Creating a custom user model**
```python 
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    email == models.EmailField(
        verbose_name='email address',
        max_length=255,
        unique=True
    )

    USERNAME_FIELD = 'email'

    def __str__(self):
        return self.email

```

**Register in admin.py**
```python
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin 
from .models import User


admin.site.register(User, UserAdmin)
```

**Create migrations**
```python 
python manage.py makemigrations apps.account
python manage.py migrate
```

**Set templates dirs**
In settings.py 
```python
TEMPLATES = [
    {
        ...
        "DIRS": [BASE_DIR / "templates"],  # new
        ...
    },
]
```

**Set Login and Logout Redirect url**
```python 
LOGIN_REDIRECT_URL = '/login'
LOGOUT_REDIRECT_URL = '/login'
```

**Set template settings for account**
```python 
touch apps/account/temp
```

**Set urls for account**
```python 
# django_project/urls.py
from django.contrib import admin 
from django.urls import path, include
from django.views.generic.base import TemplateView

urlpatterns = [
    path("", TemplateView.as_view(template_name="home.html"), name="home"),
    path("admin/", admin.site.urls),
    path("account/", include("apps.accounts.urls")),

    # To handle password_reset, password_reset_done, password_rest_confirm and password_reset_complete
    path("accounts/", include("django.contrib.auth.urls")),
]
```

```python 
#apps/account/urls.py
from django.urls import path

from .views import SignUpView

urlpatterns = [
    path("signup/", SignUpView.as_view(), name="signup"),
]

```

**Setting some views**
```python 
# accounts/views.py
from django.urls import reverse_lazy
from django.views.generic.edit import CreateView

from .forms import CustomUserCreationForm

class SignUpView(CreateView):
    form_class = CustomUserCreationForm
    success_url = reverse_lazy("login")
    template_name = "registration/signup.html"
```