import yaml
from jinja2 import Environment, PackageLoader, select_autoescape
env = Environment(
    loader=PackageLoader("generator"),
    autoescape=select_autoescape()
)
services = yaml.safe_load(open("services.yaml"))
build_template = env.get_template("build.jinja.yml")
deploy_template = env.get_template("deploy.jinja.yml")

def generate_build():
    print(build_template.render(services=services["services"]))
    pass 

def generate_deploy():
    print(deploy_template.render(services=services["services"]))
    pass

if __name__ == '__main__':
    generate_build()
    generate_deploy()