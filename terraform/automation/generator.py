import yaml
from jinja2 import Environment, PackageLoader, select_autoescape
import os

env = Environment(
    loader=PackageLoader("generator"),
    autoescape=select_autoescape()
)
OUTPUT_FOLDER = "buildspecs"
services = yaml.safe_load(open("services.yaml"))
build_template = env.get_template("build.jinja.yml")
deploy_template = env.get_template("deploy.jinja.yml")

if not os.path.exists(OUTPUT_FOLDER):
    os.mkdir(OUTPUT_FOLDER)

build_file = f'{OUTPUT_FOLDER}/build.yml'
deploy_file = f'{OUTPUT_FOLDER}/deploy.yml'

def generate_file(template_name, filename):
    with open(filename, 'w') as fp:
        fp.write(template_name.render(services=services["services"]))

if __name__ == '__main__':
    generate_file(build_template, build_file)
    generate_file(deploy_template, deploy_file)