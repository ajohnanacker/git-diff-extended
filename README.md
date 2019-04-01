# git-diff-extended
The *git-diff-extended* script replaces the standard *diff* command with *git diff* to be able to compare strings on the commandine (and not only files). Additionally we make use of the great *diff-highlight* script (https://github.com/git/git/tree/master/contrib/diff-highlight) which improves git diff highlighting to show per character differences.

##Requirements

- install *git*


##Setup

1. cp *git-diff-extended.sh* in a certain directory, e.g. *~/bin*

2. add this directory (*~/bin*) to $PATH, if not yet the case. Just add the following in *~/.bash_profile*

   ```export PATH=~/bin:$PATH```

3. add the following alias to *~/.bash_profile*

   ```alias diff=git-diff-extended.sh $1```


##To enable per-character diff highlighting we need to do the following:

1. search the *diff-highlight* script in your git installation. The *diff-highlight* tool is part of *git* distributions but unfortunately its a bit hidden in the installation

   e.g. on *MacOS* its located in */usr/local/Cellar/git/**<git-version>**/share/git-core/contrib/diff-highlight/diff-highlight*

2. cp *diff-highlight* to *~/bin* (with the small risk that you miss updates on the *diff-highlight* with newer git versions)

   alternatively you can create a link, but this means it will not work after git update (because git version is in the path)

3. Add the following to *~/.gitconfig*

```
[pager]
        diff = diff-highlight | less
        log = diff-highlight | less
        show = diff-highlight | less
```

## Usage

### To compate 2 strings

![String compare example](/images/git-diff-extended-example_001.png)
Format: ![Alt Text](url)

### The strings may also contain spaces. Just surround them with quotation marks

![String compare example (with spaces)](/images/git-diff-extended-example_002.png)
Format: ![Alt Text](url)

### If you run the command without parameters some help is displayed

![String compare example (with spaces)](/images/git-diff-extended-example_003.png)
Format: ![Alt Text](url)


