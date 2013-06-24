<?php

connect();

$last=null;
$count=0;
$err=0;
$max=($argc > 1)?$argv[1]:5000;
$fylld=null;

$diff_first=null;
$diff_total=null;

while($count < $max) {

    $last=generate_new();

    if($last !== false) {
        if(save($last)) {

            $count++;

        } else {

            echo "ERROR: couldn't save!\n";
            $err++;
            if($err > 5) {
                die("To many errors!\n");
            }

        }
    }

}

echo "Done!\n";

//Functions below...

function connect() {
    @mysql_connect("localhost","sudoku","sudoku") or die("Mysql connect error!\n");
    @mysql_selectdb("sudoku") or die("Mysql selectdb error!\n");
}

function save($arr) {
    global $fylld, $diff_first, $diff_total;

    $str1="";
    $str2="";

    for($i=0;$i<9;$i++) {
        $new[$i]=array();
        for($j=0;$j<9;$j++) {
            $str1 .= $arr[$i][$j];
            $str2 .= $fylld[$i][$j];
        }
    }

    if(is_unique($arr)) {

        $rank = round(
            ($diff_total-2) - $diff_first
        );

        return mysql_query(sprintf(
            "
            INSERT INTO `sudokus`
            (`data`,`solved`,`rank`,`time`)
            VALUES('%s','%s','%d','%u')
            ",
            mysql_real_escape_string($str1),
            mysql_real_escape_string($str2),
            $rank, time()
        ));

    }

}

function generate_new() {
    global $fylld;
    $arr=array();
    for($i=0;$i<9;$i++) {
        $arr[$i]=array();
        for($j=0;$j<9;$j++) {
            $arr[$i][$j]=0;
        }
    }
    $c=0;
    $x=0;
    $y=0;
    $f=false;
    while(!$f) {
        $n=pick_random($x,$y,$arr);
        if($n === false) {
            $c++;
            if($c > 2000) {
                return false;
            } else {
                clear_row($y,$arr);
                $x=0;
            }
        } else {
            $arr[$x][$y]=$n;
            $x+=1;
            if($x>8) {
                $x=0;
                $y+=1;
                if($y>8) {
                    $f=true;
                }
            }
        }

    }
    $fylld = copy_arr($arr);

    $rem=rand(45,65);

    for($i=0;$i<$rem;$i++) {
        $x=rand(0,8);
        $y=rand(0,8);
        $sx=$x;
        $sy=$y;
        $n=$arr[$x][$y];
        $arr[$x][$y]=0;
        while($n == 0 or !is_unique($arr,$x,$y)) {
            $arr[$x][$y]=$n;
            $x+=1;
            if($x>8) {
                $x=0;
                $y+=1;
                if($y>8) {
                    $y=0;
                }
            }
            if($x == $sx and $y == $sy) {
                return $arr;
            }
            $n=$arr[$x][$y];
            $arr[$x][$y]=0;
        }
    }

    return $arr;
}

function pick_random($x,$y,$arr) {
    $n=rand(1,9);
    for($i=0;$i<9;$i++) {
        if(can_place($x,$y,(($n+$i)%9)+1,$arr)) {
            return (($n+$i)%9)+1;
        }
    }
    return false;
}

function number_pick($x,$y,$arr) {
    $ret=array();
    for($i=0;$i<9;$i++) {
        if(can_place($x,$y,$i+1,$arr)) {
            $ret[]=$i+1;
        }
    }
    return $ret;
}

function clear_row($row,$arr) {
    for($i=0;$i<9;$i++) {
        $arr[$i][$row] = 0;
    }
    return true;
}

function can_place($x,$y,$n,$arr) {
    $sx=floor($x/3)*3;
    $sy=floor($y/3)*3;
    for($i=0;$i<9;$i++) {
        if($arr[$x][$i] == $n and $i != $y) { return false; }
        if($arr[$i][$y] == $n and $i != $x) { return false; }
        $cx=$sx+($i%3);
        $cy=$sy+(floor($i/3));
        if($cx != $x or $cy != $y) {
            if($arr[$cx][$cy] == $n) { return false; }
        }
    }
    return true;
}

function is_unique($arr,$x = null,$y = null) {
    global $diff_first, $diff_total;

    if($x != null and $y != null) {
        if(count(number_pick($x,$y,$arr)) == 1) {
            return true;
        }
    }

    $new = copy_arr($arr);
    $first = true;
    $diff_first = 0;
    $diff_total = 0;

    $empty=array();
    $delete=array();

    foreach($new as $rnum => $row) {
        foreach($row as $cnum => $cell) {
            if($cell == 0) {
                $empty[]=$rnum . $cnum;
            }
        }
    }
    $f=true;
    while($f) {
        $f=false;
        foreach($empty as $cur) {
            $ca=number_pick($cur[0],$cur[1],$new);
            if(count($ca) == 1) {

                if($x == $cur[0] and $y == $cur[1]) {
                    return true;
                }

                $new[$cur[0]][$cur[1]]=$ca[0];
                $delete[]=$cur;
                $f=true;
                if($first) {
                    $diff_first++;
                }
            }
        }
        $first=false;
        $diff_total++;
        $empty=array_diff($empty,$delete);
        $delete=array();
    }
    return (count($empty) == 0);
}

function copy_arr($arr) {
    $new=array();
    for($i=0;$i<9;$i++) {
        $new[$i]=array();
        for($j=0;$j<9;$j++) {
            $new[$i][$j]=$arr[$i][$j];
        }
    }
    return $new;
}
