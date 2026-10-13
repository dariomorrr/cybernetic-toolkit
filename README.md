# cybernetic-toolkit
A collection of SuperCollider patches realised in the context of my Master degree thesis at SMET School (Conservatory of Turin, Italy) in 2026.

This toolkit is aimed at exploring cybernetic composition and sound design, though a variety of architectures and approaches. I made it open-source because I believe in community-driven feedback and ecology of materials.

Enjoy!

## INSTALLATION
The whole Class folder should be placed in the Extensions folder that SuperCollider points to. The default path is usually:
```
/Library/Application Support/SuperCollider/Extensions/
```
You can also double check the path with the .dir method in SC.

In alternative, you can istall the quark directly from SC:

```supercollider
// install the quark
Quarks.install("https://github.com/dariomorrr/cybernetic-toolkit")

// recompile
thisProcess.recompile;
```


### SYNTHS INSTANTIATION
In SC, just call:
```supercollider
CyberneticToolkit.load;
```
The help file offers some useful examples to start navigating the toolkit.


Thanks for downloading!
