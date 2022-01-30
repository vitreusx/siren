import jinja2
from pathlib import Path
import argparse
import os
import shutil


def make_parser():
    parser = argparse.ArgumentParser(description="k8s config file resolver")
    pwd = Path(__file__).parent
    parser.add_argument("-i", "--input-dir", default=str(pwd))
    parser.add_argument("-o", "--output-dir", default="k8s.resolved")
    return parser

def main():
    parser = make_parser()
    args = parser.parse_args()
    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)

    params = {**os.environ}
    
    def resolve(input_dir: Path, output_dir: Path):
        output_dir.mkdir(parents=True, exist_ok=True)
        for root, dirs, files in os.walk(str(input_dir)):
            for name in files:
                file = Path(root) / name
                out = output_dir / Path(root).relative_to(input_dir) / name

                if file.suffix == '.j2':
                    t = jinja2.Template(open(file, "r").read())
                    text = t.render(params)
                    open(out.with_suffix(''), 'w').write(text)
                else:
                    shutil.copyfile(file, out)
            
            for name in dirs:
                resolve(input_dir / name, output_dir / name)
    
    resolve(input_dir, output_dir)

if __name__ == "__main__":
    main()