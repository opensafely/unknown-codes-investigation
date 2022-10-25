import csv
import glob

counts = {}
for path in glob.glob("output/*.csv"):
    with open(path) as f:
        reader = csv.DictReader(f)
        counts[path] = len(list(reader))


with open("output/report.txt", "w") as f:
    for path, count in counts.items():
        f.write(f"There are {count} rows in {path}")
