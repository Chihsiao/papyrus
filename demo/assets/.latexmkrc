$pdf_mode = 5;

use File::Basename;

my $input = $ARGV[-1];
if ($input =~ /\.tex$/) {
    $input = substr($input, 0, -4);
}

if ($input =~ /\.fig$/) {
    my $WORKSPACE_FOLDER = $ENV{'PAPYRUS_WORKSPACE_FOLDER'};
    my ($basename, $dir, $ext) = fileparse($input, qr/\.fig$/);
    $aux_dir = "$WORKSPACE_FOLDER/demo/.output/demo/aux/fig-$basename" if $WORKSPACE_FOLDER;
}
