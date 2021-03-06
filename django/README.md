- [Creating custom user with account app.](#creating-custom-user-with-account-app)
- [Sending email in django](#sending-email-in-django)
- [Setting Static files, templates and media](#setting-static-files-templates-and-media)

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
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _


class User(AbstractUser):
    email = models.EmailField(_('email address'), blank=True, unique=True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'first_name', 'last_name']

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

**Change apps.py** 
Change `name` from `account` to `apps.account`
```python
class AccountConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.account'

```

**Create migrations**
```python 
python manage.py makemigrations 
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
LOGIN_REDIRECT_URL = '/account/login'
LOGOUT_REDIRECT_URL = '/account/login'
```

**Set template settings for account**
```python 
cd apps/account
mkdir templates
cd templates
mkdir account
touch login.html
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
    path('account/', include("apps.account.urls"))


]
```

**`apps.account.urls` code**
This url is just copy and pasted from `django.contrib.auth.urls`

```python 
#apps/account/urls.py
from . import views
from django.urls import path

urlpatterns = [
    # For login logout
    path('login/', views.AccountLoginView.as_view(), name='login'),
    path('logout/', views.AccountLogoutView.as_view(), name='logout'),

    # For password change
    path('password_change/', views.AccountPasswordChangeView.as_view(), name='password_change'),
    path('password_change/done/', views.AccountPasswordChangeDoneView.as_view(), name='password_change_done'),

    # For Password rest, email setup is required
    path('password_reset/', views.AccountPasswordResetView.as_view(), name='password_reset'),
    path('password_reset/done/', views.AccountPasswordResetDoneView.as_view(), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', views.AccountPasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('reset/done/', views.AccountPasswordResetCompleteView.as_view(), name='password_reset_complete'),

    # For User register and edit. 
    path('register/', views.AccountRegisterView.as_view(), name='register'),
    path('update/<int:pk>', views.AccountUpdateView.as_view(), name='update'),
]

```

**Views for URL**
- This is also a copy paste from `django.contrib.auth.view`, without just creating extra `views.py` file in `apps/account` you can just reference these views from `django.contrib.auth.views`. 

- Here rather using `LoginView`, `LogoutView` directly from `django.contrib.auth.view` we are subclassing these classbased views such that `LoginView` is inherited to `AccountLoginView` so as to fit our customized need. 
- Here `AccountLoginView` is referenced to `apps/account/urls.py` file. 
- Instead of doing `path('login/', views.AccountLoginView.as_view(), name='login'),` in `apps/account/urls.py` you can also do `path('login/', views.LoginView.as_view(), name='login'),` where views.LoginView is directly imported from `django.contrib.auth.view`. 
- In each View you can set `template_name` variable to the suitable template  for each view. 
- Here we aren't setting the template_name in `AccountLoginView, AccountLogoutView` views rather we are using the default templates that are pointing to `registration` folder, so create the registration folder under `apps/account` and create the following templates
such as ` password_reset_form.html, password_reset_complete.html, password_change_form.html, logged_out.html, password_reset_confirm.html, login.html, password_change_done.html, password_reset_done.html`

```python
# apps/account/views.py 
from django.views.generic.edit import CreateView, UpdateView
from django.shortcuts import render, reverse
from django.urls import reverse_lazy
from django.contrib import messages
from .models import User
from .forms import (
    AccountRegisterForm,
    AccountUpdateForm
)
from django.contrib.auth.views import (
    LoginView,
    LogoutView,
    PasswordChangeView,
    PasswordChangeDoneView,
    PasswordResetView,
    PasswordResetDoneView,
    PasswordResetConfirmView,
    PasswordResetCompleteView,

)


class AccountLoginView(LoginView):
    template_name = 'account/registration/login.html'  # This is same in LoginView class


class AccountLogoutView(LogoutView):
    template_name = 'account/registration/logged_out.html'


class AccountPasswordChangeView(PasswordChangeView):
    template_name = 'account/registration/password_change_form.html'
    success_url = reverse_lazy('account:password_change_done')


class AccountPasswordChangeDoneView(PasswordChangeDoneView):
    template_name = 'account/registration/password_change_done.html'


class AccountPasswordResetView(PasswordResetView):
    """
    Provide password rest form
    """
    email_template_name = 'account/registration/password_reset_email.html'
    template_name = 'account/registration/password_reset_form.html'


class AccountPasswordResetConfirmView(PasswordResetConfirmView):
    template_name = 'account/registration/password_reset_confirm.html'


class AccountPasswordResetDoneView(PasswordResetDoneView):
    template_name = 'account/registration/password_reset_done.html'


class AccountPasswordResetCompleteView(PasswordResetCompleteView):
    template_name = 'account/registration/password_reset_complete.html'


class AccountRegisterView(CreateView):
    form_class = AccountRegisterForm
    template_name = 'account/registration/account_register.html'

    def form_valid(self, form):
        user = form.save(commit=False)
        user.save()
        messages.add_message(self.request, level=messages.SUCCESS, message="Account created successfully")
        return super().form_valid(form)

    def form_invalid(self, form):
        return render(self, self.request, 'account/registration/account_register.html', {
            'form': form
        })

    def get_success_url(self) -> str:
        return reverse("account:login")


class AccountUpdateView(UpdateView):
    form_class = AccountUpdateForm
    model = User
    template_name = 'account/registration/account_register.html'

    def form_valid(self, form):
        user = form.save(commit=False)
        user.save()
        messages.add_message(self.request, level=messages.SUCCESS, message="Account updated successfully")
        return super().form_valid(form)

    def form_invalid(self, form):
        return render(self, self.request, 'account/registration/account_register.html', {
            'form': form
        })

    def get_success_url(self) -> str:
        return reverse("account:login")



```

**Forms used in `account/views.py`**
```python 
# account/forms.py
from django.contrib.auth.forms import UserCreationForm, UserChangeForm, UsernameField
from .models import User


class AccountRegisterForm(UserCreationForm):
    class Meta:
        model = User
        fields = ("email",)
        field_classes = {'username': UsernameField}


class AccountUpdateForm(UserChangeForm):
    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name',)
        field_classes = {'username': UsernameField}

```

## Sending email in django


## Setting Static files, templates and media 

**Creating `templates, static and media` folder**

To set html templates and static files in django create `templates` and `static` folder in django project root directory 

```python 
mkdir static 
mkdir templates
mkdir media
```

Copy all `img, js, css, plugins` file in static directory and all `.html` files in templates directory. 

**Update Settings.py file**
Update `settings.py` file.
```python

STATIC_URL = '/static/'
STATICFILES_DIRS = [
    'static',
    BASE_DIR / "static",

]

# Change this for your convinenet
STATIC_ROOT = "C:\\Users\\user\\AppData\\Local\\Temp"
MEDIA_ROOT = BASE_DIR / "media"
MEDIA_URL = '/media/'

```

**Server static and media in dev environment**
To serve in dev environment update `urls.py` file of root project. 

```python 
# project_name/urls.py

from django.conf import settings
from django.conf.urls.static import static

if settings.DEBUG:
    # Serve media in development mode
    urlpatterns +=  static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**Use load static to load static files**
```python 
{% load static %}
```