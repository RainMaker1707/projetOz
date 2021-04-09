# projetOz

## Makefile
This project allow you to use a makefile to build, run and clean your directory.\\
These command are:
- make build -- wich build the code in a single compiled file, usualy named main.ozf\\
- make run -- which allow you to run the builded file by the precedent cmd.\\
- make clean -- which allow you to clean the directory where you build the main.ozf.\\

## GameDriver
The GameDriver function is a fucntion which take one tree as argument, the tree is built from TreeBuilder function (read bellow) 
an exemple of these tree is

```tree(q:'Porte-t-il des lunettes ?'  true: ['Harry Potter' 'Minerva McGonagall'] false: tree(q:'Est-ce que c\'est une fille ?' true:['Hermione Granger'] false:['Ron Weasley']))```

This function work on pattern matching if the pattern of the tree passed as argument is a list then return thevcharacters's name as the leaf contening list of them.
If the pattern is a tree too then ask the question on the tree and in function of answer rerun GameDrive with the appropriate subtree.