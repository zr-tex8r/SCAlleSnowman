use strict;

my $font_name = "SCAlleSnowman";
my @palette = (
  '#000000FF', #(outline)
  '#007F00FF', #(hat)
  '#FF0000FF', # red
  '#A82800FF', #(arms)
  '#3F66EAFF', #(buttons)
  '#99CEE2FF', #(snow)
  '#00B500FF', # green
  '#0000FFFF', # blue
  '#999900FF', # yellow
  '#D000D0FF', # violet
);
my $withsnow = [
  # outline, hat, muffler, arms, buttons, snow
  'uniE080', 'uniE081', 'uniE082', 'uniE083', 'uniE084', 'uniE085'
];
my $withoutsnow = [
  'uniE080', 'uniE081', 'uniE082', 'uniE083', 'uniE084'
];
my $withsnow_nm = [
  'uniE080', 'uniE081', 'uniE083', 'uniE084', 'uniE085'
];
my $withoutsnow_nm = [
  'uniE080', 'uniE081', 'uniE083', 'uniE084'
];
my @glyph = (
  ['uni2603', $withsnow,       [0, 1, 2, 3, 4, 5]],
  ['uni26C4', $withoutsnow,    [0, 1, 2, 3, 4]],
  ['uniE100', $withsnow_nm,    [0, 1, 3, 4, 5]],
  ['uniE101', $withsnow,       [0, 1, 2, 3, 4, 5]],
  ['uniE102', $withsnow,       [0, 1, 6, 3, 4, 5]],
  ['uniE103', $withsnow,       [0, 1, 7, 3, 4, 5]],
  ['uniE104', $withsnow,       [0, 1, 8, 3, 4, 5]],
  ['uniE105', $withsnow,       [0, 1, 9, 3, 4, 5]],
  ['uniE110', $withoutsnow_nm, [0, 1, 3, 4]],
  ['uniE111', $withoutsnow,    [0, 1, 2, 3, 4]],
  ['uniE112', $withoutsnow,    [0, 1, 6, 3, 4]],
  ['uniE113', $withoutsnow,    [0, 1, 7, 3, 4]],
  ['uniE114', $withoutsnow,    [0, 1, 8, 3, 4]],
  ['uniE115', $withoutsnow,    [0, 1, 9, 3, 4]],
);

sub main {

  my $ttxv = `ttx --version`; chomp($ttxv);
  ($ttxv ne '') or die "TTX is not installed";
  local $_ = $ttxv; s{^(\d+)\.(\d+).*}{$1*1000+$2}e;
  ($_ >= 3015) or die "TTX is too old ($ttxv, needs 3.15)";

  (-f "$font_name.ttf") or die "No $font_name";
  rename("$font_name.ttf", "__base.ttf");

  write_colr_ttx("$font_name.ttx");

  $_ = system("ttx -m __base.ttf $font_name.ttx");
  ($_ == 0) or "TTX failed";

  unlink("__base.ttf", "$font_name.ttx");
}

sub write_colr_ttx {
  my ($fnam) = @_;
  open(my $ho, '>', $fnam) or die "Cannot open $fnam";
  print $ho (<<'EOT');
<?xml version="1.0" encoding="UTF-8"?>
<ttFont sfntVersion="\x00\x01\x00\x00" ttLibVersion="3.15">

  <COLR>
    <version value="0"/>
EOT
  foreach (@glyph) {
    my ($gn, $lyr, $plt) = @$_;
    ($#$lyr == $#$plt) or die "Bad data(1:$gn)";
    print $ho (<<"EOT");
    <ColorGlyph name="$gn">
EOT
    foreach (0 .. $#$lyr) {
      my ($l, $p) = ($lyr->[$_], $plt->[$_]);
      (defined $l && defined $p) or die "Bad data(2:$gn)";
      print $ho (<<"EOT");
      <layer colorID="$p" name="$l"/>
EOT
    }
    print $ho (<<"EOT");
    </ColorGlyph>
EOT
  }
  my $n = @palette; print $ho  <<"EOT";
  </COLR>

  <CPAL>
    <version value="0"/>
    <numPaletteEntries value="$n"/>
    <palette index="0">
EOT
  foreach (0 .. $#palette) {
    my $c = $palette[$_]; print $ho (<<"EOT");
      <color index="$_" value="$c"/>
EOT
  }
  print $ho (<<"EOT");
    </palette>
  </CPAL>

</ttFont>
EOT
  close($ho);
}

main();
