import jinja2
from pathlib import Path
import argparse
import os
import shutil


def make_parser():
    parser = argparse.ArgumentParser(description="Jinja template renderer")

    parser.add_argument("source",
        help="Source file/template/directory")
    parser.add_argument("dest",
        nargs='?',
        help="Destination file/template/directory")
    parser.add_argument("-v", "--var",
        nargs=2, action="append",
        metavar=('name', 'value'),
        help="Variables to be used within the templates")

    return parser


def main():
    parser = make_parser()
    args = parser.parse_args()

    def morph(dest: Path):
        if dest.is_file() and dest.suffix == ".j2":
            return dest.with_suffix("")
        else:
            return Path(dest)

    source = Path(args.source)
    if args.dest:
        dest = Path(args.dest)
    else:
        dest = morph(source)

    params = dict(os.environ)
    if args.var:
        params.update(args.var)
    
    def render(source: Path, dest: Path):
        print(f"[render] {source} -> {dest}")

        if source.is_file():
            dest.parent.mkdir(parents=True, exist_ok=True)
            if source.suffix == '.j2':
                source_text = open(source, "r").read()
                template = jinja2.Template(source_text)
                rendered_text = template.render(params)
                open(dest, 'w').write(rendered_text)
            else:
                shutil.copyfile(source, dest)

        elif source.is_dir():
            for root, dirs, files in os.walk(str(source)):
                for name in [*files, *dirs]:
                    next_source = Path(root) / name
                    next_dest = dest / next_source.relative_to(source)
                    next_dest = morph(next_dest)
                    render(next_source, next_dest)

    render(source, dest)


if __name__ == "__main__":
    main()