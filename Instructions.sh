---- Kubernetes Ingress ----
Step 1 : Create APIs
public class Blog {
	private String id;
	private String title;
	private String content;
	private String author;
}

@SpringBootApplication
@RestController
public class BlogServiceApplication {
	@GetMapping("/allBlogs")
	public List<Blog> viewBlogs() {
		return Stream.of(
				new Blog("B001", "The Magic of Java Streams", "An in-depth exploration of Java Streams and their use cases.", "Alice"),
				new Blog("B002", "Spring Boot: Building REST APIs", "Step-by-step guide to building robust REST APIs with Spring Boot.", "Bob"),
				new Blog("B003", "Angular vs React: A Comparison", "A detailed comparison of Angular and React for modern web development.", "Charlie"),
				new Blog("B004", "Scaling with Microservices", "How to scale your application using microservices architecture.", "David"),
				new Blog("B005", "Kubernetes Deployment Strategies", "Different strategies for deploying applications on Kubernetes.", "Eve")
		).collect(Collectors.toList());
	}

build.gradle
............
group = 'com.kaleshrikant'
version = '1.0.0'
description = 'Demo project for Spring Boot for Kubernetes Ingress'

bootJar {
    archiveFileName = 'blog-service.jar'
    mainClass = 'com.kaleshrikant.BlogServiceApplication'
}


Dockerfile
...........
FROM openjdk:21-slim
WORKDIR /app
COPY ./build/libs/blog-service.jar /app
EXPOSE 8080
CMD ["java", "-jar", "blog-service.jar"]
---
public class Course {
	private String courseId;
	private String name;
	private double price;
}

@SpringBootApplication
@RestController
public class CourseServiceApplication {

	@GetMapping("/allCourses")
	public List<Course> viewCourses() {
		return Stream.of(
				new Course("C001", "Java Basics", 199.99),
				new Course("C002", "Spring Boot Mastery", 299.99),
				new Course("C003", "Angular for Beginners", 249.99),
				new Course("C004", "Microservices Architecture", 399.99),
				new Course("C005", "Kubernetes for Developers", 349.99)
		).collect(Collectors.toList());
	}

	public static void main(String[] args) {
		SpringApplication.run(CourseServiceApplication.class, args);
	}

}
build.gradle
............
group = 'com.kaleshrikant'
version = '1.0.0'
description = 'Demo project for Spring Boot for Kubernetes Ingress'

bootJar {
    archiveFileName = 'course-service.jar'
    mainClass = 'com.kaleshrikant.CourseServiceApplication'
}
Dockerfile
..........
FROM openjdk:21-slim
WORKDIR /app
COPY ./build/libs/course-service.jar /app
EXPOSE 8080
CMD ["java", "-jar", "course-service.jar"]
---

Step 2 : Create Docker image and push to Docker-Hub
$ docker login
	Login Succeeded

$ pwd
	spring-boot-k8s-ingress/course-service
$ docker build --no-cache -t beingshrikant/course-service:2.0 .

$ pwd
	spring-boot-k8s-ingress/blog-service
$ docker build --no-cache -t beingshrikant/blog-service:2.0 .

$ docker images
	REPOSITORY                         TAG        IMAGE ID       CREATED              SIZE
	beingshrikant/blog-service         2.0        6643fc5823a7   About a minute ago   734MB
	beingshrikant/course-service       2.0        18f2123673d8   3 minutes ago        734MB

Now, lets push both images to Docker-Hub
$ docker push beingshrikant/blog-service:2.0
$ docker push beingshrikant/course-service:2.0

Step 3 : Run in Kubernetes, need to define Service and Deployment object.

IMP : To enable ingress on Minikube
$ minikube addons enable ingress
	💡  ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.5.3
    ▪ Using image registry.k8s.io/ingress-nginx/controller:v1.12.2
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.5.3
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled



blog-service
===================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blog-service-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blog-service
  template:
    metadata:
      labels:
        app: blog-service
    spec:
      containers:
        - name: blog-service
          image: beingshrikant/blog-service:2.0
          ports:
            - containerPort: 8080

---

apiVersion: v1
kind: Service
metadata:
  name: blog-service
spec:
  type: ClusterIP
  selector:
    app: blog-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080

course-service
================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: course-service-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: course-service
  template:
    metadata:
      labels:
        app: course-service
    spec:
      containers:
        - name: course-service
          image: beingshrikant/course-service:2.0
          ports:
            - containerPort: 8080

---


apiVersion: v1
kind: Service
metadata:
  name: course-service
spec:
  type: ClusterIP
  selector:
    app: course-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080


Note : ClusterIP -> just want to expose our Service to Cluster only.

Now lets apply our configurations to create Deployments and Service
$ pwd
	/spring-boot-k8s-ingress/blog-service
$ kubectl apply -f k8s-config.yaml
	deployment.apps/blog-service-deployment created
	service/blog-service created

$ pwd
/spring-boot-k8s-ingress/course-service

$ kubectl apply -f k8s-config.yaml
	deployment.apps/course-service-deployment created
	service/course-service created

$ kubectl get all
	NAME                                                      READY   STATUS             RESTARTS          AGE
	pod/blog-service-deployment-6f7f84f44-bb465               0/1     CrashLoopBackOff   8 (2m4s ago)      18m
	pod/blog-service-deployment-6f7f84f44-bp8pz               0/1     CrashLoopBackOff   8 (109s ago)      18m
	pod/course-service-deployment-85bcb665-5r7l6              0/1     Error              2 (32s ago)       50s
	pod/course-service-deployment-85bcb665-6gb6h              0/1     CrashLoopBackOff   2 (21s ago)       50s

	NAME                                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
	service/blog-service                          ClusterIP   10.111.141.108   <none>        80/TCP           18m
	service/course-service                        ClusterIP   10.97.254.130    <none>        80/TCP           50s

	NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
	deployment.apps/blog-service-deployment               0/2     2            0           18m
	deployment.apps/course-service-deployment             0/2     2            0           50s

	NAME                                                            DESIRED   CURRENT   READY   AGE
	replicaset.apps/blog-service-deployment-6f7f84f44               2         2         0       18m
	replicaset.apps/course-service-deployment-85bcb665              2         2         0       50s

Step 4 : Defining Ingress-Resources means definig the Rules.
If the request comes as /blogs: --redirect_to--> Blog-Service and /coures: --redirect_to--> Course_Service
So for this first
$ minikube ip
	192.168.49.2

and add eof
$ cat /etc/hosts
	127.0.0.1 localhost
	127.0.1.1 ThinkPad
	# The following lines are desirable for IPv6 capable hosts
	::1     ip6-localhost ip6-loopback
	fe00::0 ip6-localnet
	ff00::0 ip6-mcastprefix
	ff02::1 ip6-allnodes
	ff02::2 ip6-allrouters
	# Added by Docker Desktop
	# To allow the same kube context to work on the host and the container:
	127.0.0.1	kubernetes.docker.internal
	# End of section
	192.168.49.2 kaleshrikant.com

as mentioned in ingress.yaml below
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
    - host: kaleshrikant.com
      http:
        paths:
          - path: "/course(/|$)(.*)"
            pathType: ImplementationSpecific
            backend:
              service:
                name: course-service
                port:
                  number: 80
          - path: "/blog(/|$)(.*)"
            pathType: ImplementationSpecific
            backend:
              service:
                name: blog-service
                port:
                  number: 80

Now check wheater you are being able to PING minikube ip or not ..
$ ping 192.168.49.2

Now finally we will apply this ingress configurion to kubernetes
$ kubectl apply -f ingress.yaml
	ingress.networking.k8s.io/microservices-ingress created

$ kubectl get pod -n ingress-nginx
	NAME                                       READY   STATUS      RESTARTS   AGE
	ingress-nginx-admission-create-zjtrh       0/1     Completed   0          3h56m
	ingress-nginx-admission-patch-txxz7        0/1     Completed   0          3h56m
	ingress-nginx-controller-67c5cb88f-l5pbz   1/1     Running     0          3h56m

$ kubectl get services -n ingress-nginx
	NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
	ingress-nginx-controller             NodePort    10.101.30.23     <none>        80:31985/TCP,443:31906/TCP   3h58m
	ingress-nginx-controller-admission   ClusterIP   10.102.206.195   <none>        443/TCP                      3h58m

$ kubectl get deployment -n ingress-nginx
	NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
	ingress-nginx-controller   1/1     1            1           3h58m

Now lets access our Blog and Cource services :
BROWSER : kaleshrikant.com/blog/allBlogs
BROWSER : kaleshrikant.com/course/allCourses