# Convert PerfPro Studio files into CycleOps ic400 files

I train indoors both at indoor cycle studios that use the PerfProStudio software.

They email me the report wiht a link to an html page with the listing of all
segments.

I would like to then have this same workout in my CycleOps ic400 indoor bike.

So I have this script that takes that html page and outputs a file that
I can import into my ic400.

## Run the test
```
rspec power_agent_converter_spec.rb
```

## Run the script

```
ruby power_agent_converter.rb
Enter the filename:
my_file.html
The file has been coverted and saved to: my_file.xml
```
