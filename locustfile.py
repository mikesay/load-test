import base64

from locust import HttpUser, TaskSet, task, between
from random import randint, choice


class WebTasks(TaskSet):

    @task
    def load(self):
        credential = '%s:%s'.format('user', 'password')
        base64string = base64.encodebytes(str.encode(credential)).replace(b'\n', b'')

        catalogue = self.client.get("/catalogue").json()
        category_item = choice(catalogue)
        item_id = category_item["id"]

        self.client.get("/")
        self.client.get("/login", headers={"Authorization":"Basic %s" % base64string})
        self.client.get("/category.html")
        self.client.get("/detail.html?id={}".format(item_id))
        self.client.delete("/cart")
        self.client.post("/cart", json={"id": item_id, "quantity": 1})
        self.client.get("/basket.html")
        self.client.post("/orders")

        wait_time = between(5, 15)


class Web(HttpUser):
    tasks = [WebTasks]
    min_wait = 0
    max_wait = 0
