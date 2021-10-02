import os
import sys
os.environ['DJANGO_SETTINGS_MODULE'] = 'sopds.settings'
sys.path.append('/sopds')
import django
from django.contrib.auth.management.commands.createsuperuser import get_user_model

django.setup()
if get_user_model().objects.filter(username=os.getenv('SOPDS_SU_NAME')):
    print('Super user already exists. SKIPPING...')
else:
    get_user_model()._default_manager.db_manager('default').create_superuser(username=os.getenv('SOPDS_SU_NAME'), email=os.getenv('SOPDS_SU_EMAIL'), password=os.getenv('SOPDS_SU_PASSWORD'))
    print('Super user created...')
