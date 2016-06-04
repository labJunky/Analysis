function [includedFiles] = excludeBetween(startTS, stopTS, files)

includedFiles = includeBetween(startTS, stopTS, files);
includedFiles = excludefiles(includedFiles, files);