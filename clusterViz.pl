#!/usr/bin/perl
use strict;
use SVG;
use Getopt::Long;
use GD;

my $VER = "1.0.0";

my $USAGE = "
usage: clusterViz.pl -i input.dat >output.svg

	-i|input		input file
	-h|help|?		show help messages
	-v|version		show version
";

my $input_file;
my $help =0;
my $version = 0;

GetOptions(
		'i|input:s'     => \$input_file,
		'h|help|?'    => \$help,
		'v|version'    => \$version
		);


if( $help ) {
	die $USAGE;
}

my (%name, %shape, %start, %end, %strand, %color);
my $w_rate = 0.6;
my $heigth = 100;


open FILE,"<$input_file" or die "Error reading input file\n";
my $i = 0;

while(<FILE>){
    chomp;
    $i++;
    my @a = split;
    $name{$i} = $a[0];
    $shape{$i} = $a[1];
    $start{$i} = $a[2];
    $end{$i} = $a[3];
    $strand{$i} = $a[4];
    $color{$i} = $a[5];
}
close FILE;

my @min = sort{$start{$a}<=>$start{$b}} keys %start;
my @max = sort{$end{$a}<=>$end{$b}} keys %end;

my $min = $start{$min[0]};
my $max = $end{$max[$#max]};

my $width = ($max-$min)/40;

my $image = SVG->new(id=>"Cluster",
        width=>$width,
        heigth=>$heigth);


my $rate = $width/($max-$min);

foreach my $k(@min){
    my $c_start =($start{$k}-$min)*$rate;
    my $c_end = ($end{$k}-$min)*$rate;
    my $c_strand = $strand{$k};
    my $c_color = $color{$k};
    my $c_name = $name{$k};

    if ($shape{$k} eq 'box'){
        &box(-name=>$c_name,-x1=>$c_start,-x2=>$c_end,-y=>$heigth/2,-filled_c=>$c_color);
    }else{
        &arrow(-name=>$c_name,-x1=>$c_start,-x2=>$c_end,-strand=>$c_strand,-y=>$heigth/2,-filled_c=>$c_color);
    }
}


sub arrow{
    my %params = @_;
    my $width = 10;
    if($params{-width}){    	
        $width = $params{-width};
    }
    my $x1 = $params{-x1};
    my $y = $params{-y};
    my $x2 = $params{-x2};
    my $strand = $params{-strand};
    my $name= $params{-name};
    my $filled_c = $params{-filled_c};
    my $poly_c = $params{-poly_c};
    my $xv;
    my $yv;
    if($strand eq '-'){
#       $x1 = $params{-x2};
#       $x2 = $params{-x1};
        $xv = [$x1,$x1+10,$x1+10,$x2,$x2,$x1+10,$x1+10];
        $yv = [$y,$y-($width*6/6),$y-($width*$w_rate),$y-($width*$w_rate),$y+($width*$w_rate),$y+($width*$w_rate),$y+($width*6/6)];

    }
    else{
        $xv = [$x1,$x2-10,$x2-10,$x2,$x2-10,$x2-10,$x1];
        $yv = [$y-($width*$w_rate),$y-($width*$w_rate),$y-($width*6/6),$y,$y+($width*6/6),$y+($width*$w_rate),$y+($width*$w_rate)];
    }

    my $points = $image->get_path(
            x=>$xv, y=>$yv,
            -type=>'polygon',
            -closed=>'true'
            );
    my $c = $image->polygon(
            %$points,
            style=>{
            'stroke'=>'black',
            'fill'=>$filled_c,
            'stroke-width'=>'0',
            'stroke-opacity'=>'0',
            'fill-opacity'=>'1'
            }
            );
    my $xx = sprintf("%.2f",$x1+(($x2-$x1)/3));
    my $yy = sprintf("%.2f",$y-3*$width/2);
    $image->text(
            style => {
            'font' =>"Arial",
            'font-size' => 12
            },
            transform => "rotate(-60,$xx,$yy)",
            x=>$xx,
            y=>$yy,
            -cdata=>$name);

}


sub box{
    my %params = @_;
    my $width = 10;
    if($params{-width}){    	
        $width = $params{-width};
    }
    my $x1 = $params{-x1};
    my $y = $params{-y};
    my $x2 = $params{-x2};
    my $name= $params{-name};
    my $filled_c = $params{-filled_c};
    my $poly_c = $params{-poly_c};
    my $xv;
    my $yv;

    $xv = [$x1,$x2,$x2,$x1];
    $yv = [$y-($width*$w_rate),$y-($width*$w_rate),$y+($width*$w_rate),$y+($width*$w_rate)];

    my $points = $image->get_path(
            x=>$xv, y=>$yv,
            -type=>'polygon',
            -closed=>'true'
            );
    my $c = $image->polygon(
            %$points,
            style=>{
            'stroke'=>'black',
            'fill'=>$filled_c,
            'stroke-width'=>'0',
            'stroke-opacity'=>'0',
            'fill-opacity'=>'1'
            }
            );

    my $xx = sprintf("%.2f",$x1+(($x2-$x1)/3));
    my $yy = sprintf("%.2f",$y-3*$width/2);

    $image->text(
            style => {
            'font' =>"Arial",
            'font-size' => 12
            },
            transform => "rotate(-60,$xx,$yy)",
            x=>$xx,
            y=>$yy,
            -cdata=>$name);
}


print $image->xmlify;

