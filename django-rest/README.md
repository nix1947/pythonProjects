# Django rest framework 

## Clone the repo 

```bash 
D:\projects\lms\lms-backend>git clone https://github.com/PearlInfotech/lms-backend
```

## Create virtualenv 
```python
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
Currently base `requirements.txt` is as follows
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
# Need to create __init__.py file otherwise test won't run
touch __init__.py
mkdir course
```
  
**Now create an `course` app inside `apps` folder**

```python
python manage.py startapp course apps/course
```

## Register your first app. 
- After creating apps register it with `django` in `settings.py` as shown below. 

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

## Testing In django

**Automated test**
Piece of code which make sure that another piece of code is working correctly under certain conditions

**Reason of testing**
- Higher application quality(less bugs)
- easier refactoring
- Easier version upgrades

**Types of test**
- Unit test
- Integration test
  - Test multiple pieces together to assure that they work will with one another
- Functional test
  - Test that everything works from end's user point of view
  - Slowest to run 
  - Also called acceptance test
  - Use tools like `selenium`

### Unit Testing in django
- Create a folder called `tests` and inside `tests` folder create the `test_serializer.py`, `test_models.py` `test_urls.py` and `test_views.py` files 

```bash 
mkdir tests
cd tests
touch __init__.py
touch test_models.py test_views.py test_serializer.py
```

**Testing urls***
```python 
# account/tests/test_urls.py

from django.test import SimpleTestCase
from django.urls import reverse, resolve
from .views import course_list, course_detail, CourseCreateView

class TestUrls(SimpleTestCase):
    def test_list_url_is_resolved(self):
        url = reverse('list')
        print(resolve(url))
        self.assertEquals(resolve(url).func, course_list)

    def test_course_create_resolve_url(self):
        url = reverse('add')
        print(resolve(url))
        self.assertEquals(resolve(url).func.view_class, CourseCreateView)

    def test_course_detail_resolve_url(self):
        url = reverse('detail', args=['some-slug])
        print(resolve(url))
        self.assertEquals(resolve(url).func.view_class, CourseCreateView)

```

***Run the test***
```bash 
python manage.py test course
```

**Testing views**
```python 
# account/tests/test_views.py
from django.tst import TestCase, Client
from django.urls import reverse
from course.models import Course, Category
import json 

class TestViews(TestCase):
    def setUp(self):
        # Run before every test method 
        self.client = Client()
        self.list_url = reverse('course:list')
        self.detail_url = reverse('course:detail', args=['project1]) 
        self.course_create_url = reverse('course:new')

        self.course1 = Course.objects.create(
            name="course1",
            slug="course 1"
        )

        self.category1 = Category.objects.create(
            title="category",
            slug="category1"
        )

    def test_course_list_GET(self):
        response = self.client.get(self.list_url)
        self.assertEquals(response.status_code, 200)
        self.assertTemplateUsed(response, "course/course_list.html)
    
    def test_course_detail_GET(self):
        response = self.client.get(self.detail_url)
        self.assertEquals(response.status_code, 200)
        self.assertTemplateUsed(response, "course/course_detail.html)

    def test_course_detail_POST_add_new_course(self):
        Course.objects.create(
            title="project1",
            category = self.category1
        )

        # Post the data
        response = self.client.post(self.course_create_url, {
            'title': 'course3',
            'description': "some description", 
          
        })

        self.assertEquals(response.status_code, 302)


    
     def test_course_detail_DELETE(self):
        course = Course.objects.create(
            title="project1",
            category = self.category1
        )

        self.delete_url = reverse('course:delete', args=[1])

        response = self.client.delete(self.delete_url)

        self.assertEquals(response.status_code, 204)
        self.assertEquals(Course.objects.count(), 0)
     

```






### Testing with pytest
```python 
pip install pytest-django
```

- create `pytest.ini` file for pytest settings along with `manage.py`

```ini 
# pytest.ini 
[pytest]
DJANGO_SETTINGS_MODULE = lms.settings
python_files = tests.py test_*.py *_tests.py
```

**tests.py** 
```python 
import pytests

def test_get_username():
    assert 1 == 1
```
**Run the test **
```python 
$ pytest
``` 
  
**Run individual test**
```python
pytest src/lms/tests.py::test_admin_user
```

**Skip a test**

```python
@pytest.mark.skip
def test_skip():
    assert 1 == 1
```

**Define custom marker in `pytest.ini`**
```
[pytest]
DJANGO_SETTINGS_MODULE = lms.settings
python_files = tests.py test_*.py *_tests.py

markers =
    slow: slow running test
```
- use the defined marker in pytest code
```python

@pytest.mark.slow
def test_example():
    print("test")
    assert 1 == 1

```

####  Pytest fixtures. 
- Use `Arrange, Act and Assert` pattern for writing a test. 
- fixture are used to feed data to the tests such as database connections, URLs to test and input data
- Generally fixtures are placed in `conftest.py` file along with `manage.py` file in src directory. 
  

```python
#conftest.py
import pytest
from django.db.contrib.auth.models import User 

@pytest.fixture()
def user_1(db):
    user = User.objects.create(username="test")

```

**Model testing**
- Use `user_1` as a parameter in your testing function. 
  
```python
from django.contrib.auth.models import User 

@pytest.mark.django_db
def test_user_create():
    User.objects.create_user("test_user", 'test@test.com', 'test')
    assert User.objects.count() == 1


@pytest.mark.django_db
def test_user_create1():
    count = User.objects.all().count()
    assert count == 0

@pytest.fixture()
def user_1(db):
    user =  User.objects.create_user('db_user')
    return user 

 
# user_1 is coming from `conftest.py`
def test_set_check_password(user_1):
    assert user_1.username = 'db_user"

```

**Model testing using faker and factory_boy**
```python
# src/conftest.py

import pytest
from django.contrib.auth import get_user_model

User = get_user_model()


@pytest.fixture()
def new_user_factory(db):
    def create_app_user(
            username="amar",
            password="amar",
            first_name="amar",
            last_name="subedi",
            email="amar.subedi@mgmail.com",
            is_staff=False,
            is_superuser=False,
            is_active=True
    ):
        user = User.objects.create_user(
            username=username,
            password=password,
            first_name=first_name,
            last_name=last_name,
            email=email,
            is_staff=is_staff,
            is_superuser=is_superuser,
            is_active=is_active
        )

        return user

    return create_app_user


@pytest.fixture
def new_user(db, new_user_factory):
    return new_user_factory()

```

***tests.py***
```python
def test_new_user(new_user):
    print("Checking username")
    assert new_user.username == 'amar'


def test_user_admin(new_user):
    print("new_user.is_staff")
    new_user.is_staff = True

```

***Running test***
```python
pytest -rp
```

#### Using `FactoryBoy and Faker` with pytest
- FactoryBoy is fixture replacement tool
- Factories are defined in a nice, clean and readable manner
- Easy to use factories for complex object
- Class based approach
  - SubFactories
  - ForeignKey, reverse ForeignKey, and Many to many relationship. 

***Install factory boy***
```python
pip install pytest-factoryboy
```

***Install faker***
```python
pip install faker
```
***Create a python file named `factories.py`***

```python
# apps/account/factories.py

import factory 
from faker import Faker
from django.contrib.auth.models import User

fake = Faker()

class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User 

    username = fake.name()
    is_staff = True 

# Create factory with relation link
class CategoryFactory(factor.django.DjangoModelFactory):
    class meta:
        model = models.Category 

    name = "electronics"

class ProductFactory(factor.django.DjangoModelFactory):
    class meta:
        model = models.Product 

    product_title = "Sample product title"
    category = factory.SubFactory(CategoryFactory)
    description = fake.text()
    slug = 'product_slug'
    regular_price = '9.99'
    discount_price = '4.99'
```

***Register the factories in `conftest.py`***

```python
#conftest.py 
from pytest_factoryboy import register
from apps.account.factories import UserFactory, ProductFactory, CategoryFactory 

#namespace user_factory
register(UserFactory)

# namespace product_factory 
register(ProductFactory)

# namespace category_factory
register(CategoryFactory)

@pytest.fixture
def new_user(db, user_factory):
    user = user_factory.create()
    return user

@pytest.fixture
def new_product(db, product_factory):
    product = product_factory.create()
    return product

```

***Use user_factory in tests.py***
```python 

@pytest.mark.django_db
def test_new_user(new_user):
    # Count 
    count = User.objects.all().count()
    assert count == 1




# These are required fields with populated data
# Last item True, False is the assertion value
# Two seperate test are run for "Newtitle" and "Second new title"
@pytest.mark.parametrize(
    "title, category, description, slug, regular_price, discount_price, validity",
    [
        ("Newtitle", 1, "New Description", "slug", "4.99", "3.99", True),
          ("Second new title", 2, "New Description", "slug", "4.99", "3.99", True)
    ]
)
def test_product_instance(
    db, product_factory, title, category, description, slug, regular_price, discount_price, validity
):

test = product_factory(
    title= title, 
    category_id = category,
    description=description,
    slug = slug,
    regular_price = regular_price,
    discount_price = discount_price,
)

item = Product.objects.all().count()

assert item == validity
```
*Here, first record will pass the test and second will fail the test* because 
`item = Product.objects.all().count() == True` in first case and `item = Product.objects.all().count() == False` in second case

**Another example**
```python
account/tests.py
@pytest.mark.parameterize(
    "username, email, password, password, validity",
    [
        ("user1", "a@a.com", "12345a", "12345a", True),
        ("user1", "a@a.com", "12345a", "", False), # no second password
        ("user1", "a@a.com", "", "12345a", False), # no first password
        ("user1", "a@a.com", "12345aa", "12345a", False),  # Password mismatch
        ("user1", "a@a.com", "12345a", "12345a", True) #email
    ]
)
@pytest.mark.django_db
def test_create_account(client, user_name, email, password, password2, validity):
    form = RegistrationForm(
        data = {
            "user_name": user_name, 
            "email": email, 
            "password": password
            "password2": password2,
        },
    )

    assert form.is_valid() is validity

```



