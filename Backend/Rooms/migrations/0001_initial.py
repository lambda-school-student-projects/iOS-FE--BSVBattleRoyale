# Generated by Django 3.0.3 on 2020-02-04 05:33

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Player',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('current_room', models.UUIDField(default=uuid.uuid4)),
                ('score', models.IntegerField(default=0)),
                ('player_avatar', models.IntegerField(default=0)),
                ('roomXPos', models.FloatField(default=0)),
                ('roomYPos', models.FloatField(default=0)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]