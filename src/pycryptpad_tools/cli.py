import sys

from click import echo, group, option, pass_context
from eliot import start_task, to_file, log_call

from pycryptpad_tools.padapi import PadAPI


to_file(sys.stderr)


# base_url = "http://cryptpad-local:3000"
base_url = "https://cryptpad.piratenpartei.de"


def pad_api(ctx):
    return PadAPI(ctx.obj['BASE_URL'], ctx.obj['HEADLESS'])


@log_call
def read_infile(infile):
    if infile == "-":
        return sys.stdin.read()
    else:
        with open(infile) as f:
            return f.read()


@group()
@option('--base_url', default=base_url)
@option('--headless/--no-headless', default=True)
@pass_context
def cli(ctx, base_url, headless):
    ctx.ensure_object(dict)
    ctx.obj['BASE_URL'] = base_url
    ctx.obj['HEADLESS'] = headless


@cli.command()
@pass_context
@option("--infile", default=None)
def create(ctx, infile):
    with start_task(action_type="create pad"):
        args = []
        if infile:
            args.append(read_infile(infile))

        with pad_api(ctx) as api:
            pad_info = api.create_pad(*args)

    echo(pad_info["url"])


@cli.command()
@pass_context
@option('--key')
def get_content(ctx, key):
    with start_task(action_type="fetch pad"):
        with pad_api(ctx) as api:
            api.open_pad(key)
            content = api.get_pad_content()

    echo(content)


@cli.command()
@pass_context
@option('--key')
@option("--infile", default="-")
def set_content(ctx, key, infile):
    with start_task(action_type="set pad"):
        content = read_infile(infile)

        with pad_api(ctx) as api:
            api.open_pad(key)
            api.set_pad_content(content)
