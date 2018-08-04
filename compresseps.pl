#!/usr/bin/perl

$lossy3 = 0; # keep 3 sig digits
$lossy4 = 1; # keep 4 sig digits

%tokens = ( "lineto", "l",
            "moveto", "m\n",
            "fill", "f",
            "grestore", "gr",
            "gsave", "gs",
            "translate", "t",
            "rotate", "r",
            "stringwidth", "sw",
            "newpath", "np",
            "closepath", "cp",
            "stroke", "s" );

$id = "\%Neil\'s jgraph Compression Tool:";
while(<>) {
  goto needheaders if(!/^%/);
  print;
  goto headerpresent if(/^$id/);
}

needheaders:
print "$id begin\n";
foreach $t ( sort keys %tokens ) {
  print "/$tokens{$t} \{$t\} bind def\n";
}
print "$id end\n";


headerfinished:
# print STDERR "working";
while(<>) {
  foreach $t ( keys %tokens ) {
    s/\b$t\b/$tokens{$t}/g;
  }
  s/\b-?0.000000/0/g;
  s/\b-?0.000\b/0/g;
  s/\.0+ / /g;
  s/  / /g;
  s/ 0 r\b//g; # 0 rotate is a noop.
  if($lossy4) { # reduce to 4 sig figures.
    s/\b(0\.0*[1-9]\d\d\d)\d+/$1/g;
    s/\b([1-9]\.\d\d\d)\d+/$1/g;
    s/\b([1-9]\d\.\d\d)\d+/$1/g;
    s/\b([1-9]\d\d\.\d)\d+/$1/g;
    s/\b([1-9]\d\d\d)(\d*)(?{ print $l = '0' x length($^N)})\.\d*/$1$l.0/g;
  }
  if($lossy3) { # reduce to 4 sig figures.
    s/\b(0\.0*[1-9]\d\d)\d+/$1/g;
    s/\b([1-9]\.\d\d)\d+/$1/g;
    s/\b([1-9]\d\.\d)\d+/$1/g;
    s/\b([1-9]\d\d)(\d*)(?{ print $l = '0' x length($^N)})\.\d*/$1$l.0/g;
  }
  # then remove trailing zeroes.
  s/(\.0*[1-9]+)0+ /$1 /g;
  s/0.5336 0.5336 JDE/0.5 0.5 JDE/g;
  if(/\d l$/) { 
    # if($l ne $_ && $ll ne $_) {  
    if($l ne $_) {  
      $ll = $l;
      $l = $_;
      print;
    }
  } elsif(/gr gs [\d\.]+ [\d\.]+ t np 0.5\d* 0.5\d* JDE gs f gr s/) {
    if($l ne $_ && $ll ne $_) {  
      $ll = $l;
      $l = $_;
      s/ gs f gr / f /;  # could be a bad idea.
      print;
    }
  } else {
    undef($l);
    undef($ll);
    print;
  }
}
# print STDERR "worked";

headerpresent:
while(<>) {
  print;
  goto headerfinished if(/^$id/);
}
