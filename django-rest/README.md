# Django rest framework 

## Clone the repo 

```bash 
D:\>git clone https://github.com/PearlInfotech/lms-backend
```

## Create a `virtualenv` environment
```python
# venv is the name of the virtual environment
virtualenv ven

```

## Active and install packages. 
```python
# Activation
venv\Scripts\activate.bat

# Install core packages. 
pip install django 
pip install djangorestframework
```


## Create requirement files
 `requirements.txt` is as follows
 
```python
Django
djangorestframework
```
```python 
pip freeze > requirements.txt
```

## Create django project 
```python 
django-admin startproject lms

# Rename lms parent folder as src folder
mv lms src
```

## Open `src` folder using Pycharm or other IDE of your choice such as vscode
```python
code src
```

## Create your first app
- In django `apps` are equivalent to `module` in java project. 
- So let's create an `course` module aka `app` 
- Create a folder called `apps` and inside app create a folder with module name such as `course` 

```python 
mkdir apps 
cd apps
mkdir course
```
  
**Now create an `course` app inside `apps` folder**

```python
python manage.py startapp course apps/course
```

## Register your first app. 
- After creating apps register it in your  `project` using `settings.py` file as shown below. 

```python 
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Registered apps
    'apps.course'
]
```

change the `default` name of your app in `apps.py` file of `course` app as shown below. 

```python 
# apps/course/apps.py
from django.apps import AppConfig


class CourseConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    # Change from course to 'apps.course'
    name = 'apps.course'

```

## Setting up Authorization module
- create an `account` apps as an `authentication and authorization` module. 

```python 
mkdir -p apps/account
```

```python 
python manage.py createapp account apps/account
```
Register the `account` app with django project

```python 
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Registered apps
    'apps.course',
    'apps.account'
]
```

## Creating a custom User model 

```python
#apps/account/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    updated_date = models.DateTimeField(auto_now_add=True)
    is_expired = models.BooleanField(default=False)
```

## Create and run the migration
```python 
# make migrations
python manage.py makemigrations account 

# Run the migration
python manage.py migrate account
```

## Register account app in django admin. 
- Registration of `app` in django admin is done so as to perform `CRUD` operation for testing purpose. 
```python
#apps/account/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

admin.site.register(User, UserAdmin)

```

## Creating super user to login in django dashboard 

```python
# username: admin, amar
# password: admin123 , %^&*(P(POIUYT12344

python manage.py createsuperuser
```
