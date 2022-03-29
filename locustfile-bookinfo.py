import base64

from locust import HttpUser, TaskSet, task, between
from random import randint, choice


class WebTasks(TaskSet):

    @task
    def load(self):
        self.client.get("/productpage?u=normal")
        wait_time = between(5, 15)


class Web(HttpUser):
    tasks = [WebTasks]
    min_wait = 0
    max_wait = 0
