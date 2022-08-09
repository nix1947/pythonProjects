- [Django rest framework](#django-rest-framework)
  - [Clone the repo](#clone-the-repo)
  - [Create a `virtualenv` environment](#create-a-virtualenv-environment)
  - [Active and install packages.](#active-and-install-packages)
  - [Create requirement files](#create-requirement-files)
  - [Install from requirements file](#install-from-requirements-file)
  - [Create django project](#create-django-project)
  - [Open `src` folder using Pycharm or other IDE of your choice such as vscode](#open-src-folder-using-pycharm-or-other-ide-of-your-choice-such-as-vscode)
  - [Create your first app](#create-your-first-app)
  - [Register your first app.](#register-your-first-app)
  - [Setting up Authorization module](#setting-up-authorization-module)
  - [Creating a custom User model](#creating-a-custom-user-model)
  - [Create and run the migration](#create-and-run-the-migration)
  - [Register account app in django admin.](#register-account-app-in-django-admin)
  - [Creating super user to login in django dashboard](#creating-super-user-to-login-in-django-dashboard)
  - [Common reusable model  in django](#common-reusable-model--in-django)
  - [Creating Apis](#creating-apis)
  - [Views in rest framework](#views-in-rest-framework)
    - [Function based view](#function-based-view)
    - [Class based views](#class-based-views)
    - [Creating API root endpoint](#creating-api-root-endpoint)
  - [Adding swagger api to rest framework](#adding-swagger-api-to-rest-framework)
    - [Enable function based view with swagger.](#enable-function-based-view-with-swagger)
  - [Testing In django](#testing-in-django)
    - [Unit Testing in django](#unit-testing-in-django)
    - [Testing with pytest](#testing-with-pytest)
      - [Pytest fixtures.](#pytest-fixtures)
      - [Using `FactoryBoy and Faker` with pytest](#using-factoryboy-and-faker-with-pytest)

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

## Install from requirements file 
```python 
pip install -r requirements.txt
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
## Common reusable model  in django  
- In core project create `abstract_models.py` file with meta `abstract=True` to inherits the common fields in other django models 

```python 
# lms/abstract_models.py
from django.db import models


class TimeStampModel(models):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

```
**Relations**
```python
# course/models.py
from django.db import models

from apps.account.models import User
from lms.abstract_model import TimeStampModel


class Category(TimeStampModel):
    title = models.CharField(max_length=255, unique=True)
    description = models.TextField()
    # format: class(in_plural)+ field_name
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, related_name="categories_created_by", null=True)
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, related_name="categories_updated_by", null=True)

    class Meta:
        ordering = ['-created_date']


class Course(TimeStampModel):
    title = models.CharField(max_length=255, unique=True)
    description = models.TextField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, related_name="courses_created_by", null=True)
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, related_name="courses_updated_by", null=True)
    thumbnail = models.ImageField(upload_to="thumbnail/")
    video_path = models.FileField(upload_to="videos/")

    def __str__(self):
        return self.title


class CourseCategory(TimeStampModel):
    course = models.ForeignKey(Course, on_delete=models.SET_NULL, related_name="course_categories_course", null=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, related_name="course_categories_category",
                                 null=True)

    def __str__(self):
        return self.course.title + " " + self.category.title

```

## Creating Apis
- Based on the created models, to create api, we require three files `serializers.py`  to format the data, just work like `forms.py` in django, `views.py` file to process the client request and `urls.py` for api endpoints. 
- Fields level validation can be done by adding `validate_field_name` methods to serializer class. 

```python
    def validate_password(self, value):
        if len(value) < 8 :
            raise serializers.ValidationError("Minimum length of password should be eight")
        return value
         
``` 

- Object level validation can be done inside `validate` method. 

```python
from rest_framework import serializers
from rest_framework.validators import UniqueValidator

class EventSerializer(serializers.Serializer):
    description = serializers.CharField(max_length=100)
    start = serializers.DateTimeField()
    finish = serializers.DateTimeField()
    # By default django email fields have not added unique=True
    email = serializers.EmailField(max_length=255, validators=[UniqueValidator(queryset=User.objects.all())])

    def validate(self, data):
        """
        Check that start is before finish.
        """
        if data['start'] > data['finish']:
            raise serializers.ValidationError("finish must occur after start")
        return data

```

***Serializers.py** 
```python
# apps/course/serializers.py
from rest_framework import serializers
from .models import Course, Category


class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = '__all__'

```

***Views.py***
```python
# apps/course/views.py
from rest_framework import viewsets
from .models import Course, Category
from .serializers import CourseSerializer, CategorySerializer


class CourseViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = Course.objects.all().order_by('-updated_date')
    serializer_class = CourseSerializer

```

***root_api_urls.py**
```python
# lms/api_urls.py
from rest_framework import routers

from apps.account import views as account_views
from apps.course import views as course_views

router = routers.DefaultRouter()

# Account app router
router.register("users", account_views.UserViewSet)
router.register("permissions", account_views.PermissionViewSet)
router.register("roles", account_views.GroupViewSet)

# Course app router
router.register(r'courses', course_views.CourseViewSet)
router.register(r'categories', course_views.CategoryViewSet)
router.register(r'keywords', course_views.KeyWordViewSet)
router.register(r'sections', course_views.CourseSectionViewSet)
router.register(r'contents', course_views.CourseSectionContentViewSet)
```

***urls.py**
```python 
# lms_project/urls.py
from django.contrib import admin
from django.urls import include, path

from . import api_urls

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    path('api/', include(api_urls.router.urls))

]

```

***Setup Pagination***
```python
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 10
}
```

***Authentication**
- Use `djangorestframework-simplejwt` for authentication
- **Installation**: `pip install djangorestframework-simplejwt`
- Update in settings.py file 


```python
REST_FRAMEWORK = {
  
    'DEFAULT_AUTHENTICATION_CLASSES': (
    
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )

```


## Views in rest framework

### Function based view

  - Use `Request` object which is the extension of `HTTPRequest`
  - `request.data` is similar to `request.POST` 
  - `request.POST`  # Only handles form data.  Only works for 'POST' method.
  - `request.data  # Handles arbitrary data.  Works for 'POST', 'PUT' and 'PATCH' methods.
  - Use `Response(data)` to send the data which is equivalent to `TemplateResponse`
  - use `@api_view` decorator to work with function based view
  - Use `APIView` to work with classed based view
  
  ***Views.py***


```python
  from  rest_framework.decorators import api_view
  from rest_framework.response import Response 
  from rest_framework import status

    @api_view(['GET', 'POST'])
    def course_list(request):
        if request.method == 'GET':
            books = Course.objects.all()
            serializer = CourseSerializer(books, many=True)
            return Response(serializer.data)

        elif request.method == 'POST':
            # Processing form data
        serializer = CourseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @api_view(['GET', 'PUT', 'DELETE'])
    def book_detail(request, pk):
        """
        Retrieve, update or delete a code snippet.
        """
        try:
            snippet = Course.objects.get(pk=pk)
        except Course.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        if request.method == 'GET':
            serializer = CourseSerializer(snippet)
            return Response(serializer.data)

        elif request.method == 'PUT':
            serializer = CourseSerializer(snippet, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        elif request.method == 'DELETE':
            snippet.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
```

### Class based views
- Use explicit two view `ListView` and `DetailView`, ListView will server `List` of object and `creating` of object while DetailView serve `Read, Update and Delete` actions. 

***Permission.py*** 
```python
from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions are only allowed to the owner of the snippet.
        return obj.owner == request.user

```

***ListView**
```python
from snippets.models import Snippet
from snippets.serializers import CourseSerializer
from django.http import Http404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import permissions


class CourseList(APIView):
    """
    List all snippets, or create a new snippet.
    """

    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]


    def get(self, request, format=None):
        snippets = Course.objects.all()
        serializer = CourseSerializer(snippets, many=True)
        return Response(serializer.data)

    def post(self, request, format=None):
        serializer = CourseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

    def perform_create(self, serializer):
        serializer.created_by = self.request.user 
        serializer.save()
        
     

```

***Detail View***
```python
class CourseDetail(APIView):
    """
    Retrieve, update or delete a course instance.
    """
    def get_object(self, pk):
        try:
            return Course.objects.get(pk=pk)
        except Course.DoesNotExist:
            raise Http404

    def get(self, request, pk, format=None):
        course = self.get_object(pk)
        serializer = CourseSerializer(Course)
        return Response(serializer.data)

    def put(self, request, pk, format=None):
        course = self.get_object(pk)
        serializer = CourseSerializer(course, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk, format=None):
        course = self.get_object(pk)
        course.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

***Using viewsets***

```python
class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all().order_by('-updated_date')
    serializer_class = CourseSerializer
```
- Equivalent code to process `POST and GET` request  by viewsets are as follows
  

```python
from rest_framework import viewsets

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all().order_by('-updated_date')
    serializer_class = CourseSerializer
    permission_classes = [IsAuthenticated, ]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

    def list(self, request, *args, **kwargs):
        # Mapped to GET request to list all objects
        # GET /courses
        # Reverse url: "basename-list"
        # Base name is given while registering to the router
        pass

    def create(self, request, *args, **kwargs):
        # Mapped to CREATE request
        # POST /courses
        # Reverse url: "basename-list"
        pass

    def retrieve(self, request, *args, **kwargs):
        # Mapped to GET request /courses/:1
        # GET /courses/:1
        # Reverse url: "basename-detail"
        pass

    def update(self, request, *args, **kwargs):
        # Mapped to PUT request /courses/:1
        # PUT /courses/:1
        # Reverse url: "basename-list"
    
        pass

    def partial_update(self, request, *args, **kwargs):
        # Mapped to PATCH request /courses/:1
        # PATCH /courses/:1
        # Reverse url: "basename-list"
        pass

    def destroy(self, request, *args, **kwargs):
        # Mapped to DELETE request /courses/:1
        # DELETE /courses/:1
        # Reverse url: "basename-list"
        pass
```
The above `CourseViewSet` can be mapped to the following explicit URL by creating a `Router`

***urls.py** 
```python
from rest_framework import routers

router = routers.DefaultRouter()
# basename are useful to retrieve the urls in reverse.
router.register(r'courses', course_views.CourseViewSet, basename="courses")

```
Now register the `router.urls` in `urlpatterns`  as shown below.

```python
urlpatterns = [
path('admin/', admin.site.urls),
path('api/', include(api_urls.router.urls)), 
]


``` 

Registering simple `ClassBased` Generic view explicitly in `urls.py` as shown below.

***urls.py***

```python
from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from course import views

urlpatterns = [
    path('courses/', views.SnippetList.as_view()),
    path('courses/<int:pk>/', views.CourseDetail.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
```

- Shortcuts of above mentioned `ListAPIView` and `DetailAPIView` can be replaced by the following view given below

```python
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer
from rest_framework import generics


class CourseList(generics.ListCreateAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer


class SnippetDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
```

### Creating API root endpoint
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'users': reverse('user-list', request=request, format=format),
        'snippets': reverse('snippet-list', request=request, format=format)
    })

```

## Adding swagger api to rest framework
- Install `drf_yasg` 
  
```python 
pip install -U drf-yasg
```

- Updated in `settings.py` file 
  
```python 
INSTALLED_APPS = [
   ...
   'django.contrib.staticfiles',  # required for serving swagger ui's css/js files
   'drf_yasg',
   ...
]
```

- Update Root `urls.py` file 

```python
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
   openapi.Info(
      title="MOF LMS API",
      default_version='v1',
      description="lms",
      terms_of_service="http://lms.mof.gov.np",
      contact=openapi.Contact(email="it@snippets.local"),
   ),
   public=True,
   permission_classes=[permissions.AllowAny],
)

urlpatterns = [
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
   re_path(r'^swagger/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
   re_path(r'^redoc/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
]

```

- The exposed endpoints are 
    - A JSON view of your API specification at /swagger.json
    - A YAML view of your API specification at /swagger.yaml
    - A swagger-ui view of your API specification at /swagger/
    - A ReDoc view of your API specification at /redoc/



### Enable function based view with swagger.

```python
from drf_yasg.utils import swagger_auto_schema

@swagger_auto_schema(
    methods=['post'],
    request_body=UserRegisterSerializer,
    responses={200: UserRegisterSerializer},
    operation_description="User registration"
)
@api_view(['POST'])
def user_register(request):
    if request.method == 'POST':
        user = UserRegisterSerializer(data=request.data)
        if user.is_valid():
            user.save()
            return Response(user.data, status=status.HTTP_201_CREATED)

        return Response(user.errors, status=status.HTTP_400_BAD_REQUEST)

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



