#!/usr/bin/perl 

use warnings; 

 

if (@ARGV != 5) { 

	 print STDERR "Usage: $0 <path_to_database> <path_to_database_output> <path-to-data-files-output> <training_percent(0-1)> <test_percent(0-1)> \n"; 

	 print "Example perl ~/Desktop/CorpusValquiria/random_rearrange.pl ~/Desktop/CorpusValquiria ~/Desktop/CorpusV ~/kaldi/kaldi/egs/valquiria/ivec/data 0.5 0.5 "; 

	 exit(1) 

} 

 

if($ARGV[3] + $ARGV[4] gt 1){ 

	 print STDERR "La suma del % de entrenamiento y prueba no deben exceder el 1.0 \n"; 

	 exit(1)  

} 

 

($data_base,$data_output,$data_files_output,$train_percent,$test_percent) = @ARGV; 

 

my $out_test_dir = "$data_output/test"; 

my $out_train_dir = "$data_output/train"; 

 

if (-d "$data_output"){ 

	 system("rm -r $data_output"); 

} 

 

if(-d "$data_files_output"){ 

	 system("rm -r $data_files_output") 

} 

 

if (system("mkdir -p $out_test_dir") != 0) { 

	 die "Error making directory $out_test_dir";  

} 

 

if (system("mkdir -p $out_train_dir") != 0) { 

	 die "Error making directory $out_train_dir";  
}
print("C\nrea carpeta \"data\" de salida\n");

if (system("mkdir -p $data_files_output/train") != 0) { 

	 die "Error making directory $data_files_output/train";  

} 
print("\nCrea carpeta \"data\\train\" de salida\n");

 

if (system("mkdir -p $data_files_output/test") != 0) { 

	 die "Error making directory $data_files_output/test";  

} 
print("\nCrea carpeta \"data\\test\" de salida\n");
 

if (system("mkdir -p $data_files_output/valquiria_test") != 0) { 

	 die "Error making directory $data_files_output/valquiria_test";  

} 
print("\nCrea carpeta \"data\\valquiria_test\" de salida\n");
 

opendir my $dh, "$data_base/wav" or die "Cannot open directory: $!"; 
print("\nAbre la base de datos\n");
my @spkr_dirs = sort grep {-d "$data_base/wav/$_" && ! /^\.{1,2}$/} readdir($dh); 

closedir $dh; 

 

my $total_spkrs = @spkr_dirs; 

$f_spkrs = $total_spkrs/2; 

$m_spkrs = $total_spkrs/2; 

my $n_test_spkrs = $total_spkrs*$test_percent; 

my $n_train_spkrs = $total_spkrs*$train_percent; 

#my @f_spkrs = grep(/^idF/, @spkr_dirs); 
my @f_spkrs = grep(/^01/, @spkr_dirs); 
#my @m_spkrs = grep(/^idM/, @spkr_dirs); 
my @m_spkrs = grep(/^02/, @spkr_dirs); 
 

%n_occupied_ftest = (); 

%n_occupied_mtest = (); 

 

my @f_indexes_test = (); 

my @m_indexes_test = (); 

 

for (1..$n_test_spkrs){ 

my $random_number; 

	 if($_ % 2 == 0){ 

	 	 do{ 

	 	  

	 	 	 $random_number = int(rand($f_spkrs)); 

	 	 	  

	 	 	  

	 	 }while(exists $n_occupied_ftest{$random_number}); 

	 	  

	 	 $n_occupied_ftest{$random_number} = $random_number; 

	 	  

	 }else{  

	 	 do{ 

	 	  

	 	 	 $random_number = int(rand($m_spkrs)); 

	 	 	  

	 	 	  

	 	 }while(exists $n_occupied_mtest{$random_number}); 

	 	  

	 	 $n_occupied_mtest{$random_number} = $random_number; 

	 	  

	 } 

} 

 

push(@f_indexes_test,keys %n_occupied_ftest); 

push(@m_indexes_test,keys %n_occupied_mtest); 

 

print("Hablantes Femeninas elegidas al azar para la prueba: \n"); 

foreach (@f_indexes_test){ 

	 my $spkr = $_; 

	 print("$f_spkrs[$spkr]\n"); 

	 system("cp -R $data_base/wav/$f_spkrs[$spkr] $out_test_dir"); 

	} 

 

print("Hablantes Masculinos elegidos al azar para la prueba: \n"); 

foreach (@m_indexes_test){  

	 my $spkr = $_; 

	 print("$m_spkrs[$spkr]\n"); 

	 system("cp -R $data_base/wav/$m_spkrs[$spkr] $out_test_dir"); 

	 } 

 

%n_occupied_ftrain = (); 

%n_occupied_mtrain = (); 

 

for (1..$n_train_spkrs){ 

my $random_number; 

	 if($_ % 2 == 0){ 

	 	 do{ 

	 	  

	 	 	 $random_number = int(rand($f_spkrs)); 

	 	 	  

	 	 	  

	 	 }while(exists $n_occupied_ftest{$random_number} || exists $n_occupied_ftrain{$random_number}); 

	 	  

	 	 $n_occupied_ftrain{$random_number} = $random_number; 

	 	  

	 }else{  

	 	 do{ 

	 	  

	 	 	 $random_number = int(rand($m_spkrs)); 

	 	 	  

	 	 	  

	 	 }while(exists $n_occupied_mtest{$random_number} || exists $n_occupied_mtrain{$random_number} ); 

	 	  

	 	 $n_occupied_mtrain{$random_number} = $random_number; 

	 } 

} 

my @f_indexes_train = (); 

my @m_indexes_train = (); 

 

push(@f_indexes_train,keys %n_occupied_ftrain); 

push(@m_indexes_train,keys %n_occupied_mtrain); 

 

print("Hablantes Femeninas elegidas al azar para el entrenamiento: \n"); 

foreach (@f_indexes_train){ 

	 my $spkr = $_;  

	 print("$f_spkrs[$spkr]\n"); 

	 system("cp -R $data_base/wav/$f_spkrs[$spkr] $out_train_dir"); 

} 

 

print("Hablantes Masculinos elegidos al azar para el entrenamiento: \n"); 

foreach (@m_indexes_train){  

	 my $spkr = $_; 

	 print("$m_spkrs[$spkr]\n"); 

	 system("cp -R $data_base/wav/$m_spkrs[$spkr] $out_train_dir"); 

} 

 
print("\nFILES: $data_files_output/train/utt2spk\n");
print("\n$data_output/data/train/utt2spk\n");
open(SPKR_TRAIN, ">", "$data_files_output/train/utt2spk") or die "could not open the output file $data_output/data/train/utt2spk"; 

open(WAV_TRAIN, ">", "$data_files_output/train/wav.scp") or die "could not open the output file $data_output/data/train/wav.scp"; 

 

opendir my $dh_train, "$out_train_dir" or die "Cannot open directory: $!"; 

my @train_spkr_dirs = grep {-d "$out_train_dir/$_" && ! /^\.{1,2}$/} readdir($dh_train); 

closedir $dh_train; 

 

#foreach (@train_spkr_dirs) { 
#
#	 	 my $spkr_id = $_; 
#
#	 	 opendir my $dh, "$out_train_dir/$spkr_id/" or die "Cannot open directory: $!"; 
#
#	 	 my @rec_dirs = grep {-d "$out_train_dir/$spkr_id/$_" && ! /^\.{1,2}$/} readdir($dh); 
#
#	 	 closedir $dh; 

#	 	 foreach (@rec_dirs) { 
		foreach (@train_spkr_dirs) {
	 	 	 my $rec_id = $_; 

	 	 	 #opendir my $dh, "$out_train_dir/$spkr_id/$rec_id/" or die "Cannot open directory: $!"; 
	 	 	 opendir my $dh, "$out_train_dir/$rec_id/" or die "Cannot open directory: $!"; 
	 	 	 my @files = map{s/\.[^.]+$//;$_}grep {/\.wav$/} readdir($dh); 

	 	 	 closedir $dh; 

	 	 	 foreach (@files) { 

	 	 	 	 my $name = $_; 

	 	 	 	 #my $wav = "$out_train_dir/$spkr_id/$rec_id/$name.wav"; 
	 	 	 	 my $wav = "$out_train_dir/$rec_id/$name.wav"; 
	 	 	 	 #my $utt_id = "$spkr_id-$rec_id-$name"; 
	 	 	 	my $utt_id = "$rec_id-$name";
	 	 	 	 print WAV_TRAIN "$utt_id", " $wav", "\n"; 

	 	 	 	 #print SPKR_TRAIN "$utt_id", " $spkr_id", "\n"; 
	 	 	 	 print SPKR_TRAIN "$utt_id", " $rec_id", "\n"; 
	 	 	 } 

	 	 } 

#	 } 

 

	 close(SPKR_TRAIN) or die; 

	 close(WAV_TRAIN) or die; 

 

open(SPKR_TEST, ">", "$data_files_output/test/utt2spk") or die "could not open the output file $data_output/data/test/utt2spk"; 

open(WAV_TEST, ">", "$data_files_output/test/wav.scp") or die "could not open the output file $data_output/data/test/wav.scp"; 

 

opendir my $dh_test, "$out_test_dir" or die "Cannot open directory: $!"; 

my @test_spkr_dirs = grep {-d "$out_test_dir/$_" && ! /^\.{1,2}$/} readdir($dh_test); 

closedir $dh_test; 

 
print("\n\nspk2utt\n\n");
#foreach (@test_spkr_dirs) { 
#
#	 	 my $spkr_id = $_; 
#	 	 print("\nFOREACH1: $spkr_id");
#	 	 opendir my $dh, "$out_test_dir/$spkr_id/" or die "Cannot open directory: $!"; 
#	 	 
#	 	 my @rec_dirs = grep {-d "$out_test_dir/$spkr_id/$_" && ! /^\.{1,2}$/} readdir($dh); 
#	 	 print("rec_dirs: $rec_dirs");
#	 	 closedir $dh; 

#	 	 foreach (@rec_dirs) { 
		foreach (@test_spkr_dirs) {
	 	 	 my $rec_id = $_; 
	 	 	 print("\nFOREACH2: $rec_id");
	 	 	 #opendir my $dh, "$out_test_dir/$spkr_id/$rec_id/" or die "Cannot open directory: $!";
	 	 	 opendir my $dh, "$out_test_dir/$rec_id/" or die "Cannot open directory: $!";  

	 	 	 my @files = map{s/\.[^.]+$//;$_}grep {/\.wav$/} readdir($dh); 
	 	 	 
	 	 	 closedir $dh; 

	 	 	 foreach (@files) { 

	 	 	 	 my $name = $_; 

	 	 	 	 #my $wav = "$out_test_dir/$spkr_id/$rec_id/$name.wav"; 
	 	 	 	 my $wav = "$out_test_dir/$rec_id/$name.wav";
	 	 	 	 #my $utt_id = "$spkr_id-$rec_id-$name"; 
	 	 	 	my $utt_id = "$rec_id-$name";
	 	 	 	 print WAV_TEST "$utt_id", " $wav", "\n"; 

	 	 	 	 #print SPKR_TEST "$utt_id", " $spkr_id", "\n"; 
	 	 	 	 print SPKR_TEST "$utt_id", " $rec_id", "\n"; 

	 	 	 } 

	 	 } 

#	 } 

 

	 close(SPKR_TEST) or die; 

	 close(WAV_TEST) or die; 

	  

my $data_output_test = "$data_files_output/test"; 

 

my $data_output_train = "$data_files_output/train"; 

 

if (system( 

	 "~/kaldi/egs/voxceleb/v1/utils/utt2spk_to_spk2utt.pl $data_output_test/utt2spk >$data_output_test/spk2utt") != 0) { 

	 die "Error creating spk2utt file in directory $data_output_test"; 

} 

system("env LC_COLLATE=C ~/kaldi/egs/voxceleb/v1/utils/fix_data_dir.sh $data_output_test"); 

if (system("env LC_COLLATE=C ~/kaldi/egs/voxceleb/v1/utils/validate_data_dir.sh --no-text --no-feats $data_output_test") != 0) { 

	 die "Error validating directory $data_output_test"; 

} 

 

if (system( 

	 "~/kaldi/egs/voxceleb/v1/utils/utt2spk_to_spk2utt.pl $data_output_train/utt2spk >$data_output_train/spk2utt") != 0) { 

	 die "Error creating spk2utt file in directory $data_output_train"; 

} 

system("env LC_COLLATE=C ~/kaldi/egs/voxceleb/v1/utils/fix_data_dir.sh $data_output_train"); 

if (system("env LC_COLLATE=C ~/kaldi/egs/voxceleb/v1/utils/validate_data_dir.sh --no-text --no-feats $data_output_train") != 0) { 

	 die "Error validating directory $data_output_train"; 

} 

 

open(TRIAL_IN, "<", "$data_output_test/utt2spk") or die "could not open the input file $data_output_test/utt2spk"; 

 

my @trial_spkr_utts = (); 

 

while(<TRIAL_IN>){ 

	 chomp; 

	 my($trial_spkr_utt, $trial_spkrs) = split; 

	 push(@trial_spkr_utts,$trial_spkr_utt); 

} 

 

close(TRIAL_IN) or die; 

 

open(TRIAL_OUT, ">", "$data_files_output/valquiria_test/trials") or die "could not open the output file $data_files_output/trials"; 

 

my $ind = 0; 

my $number_trials = 3;

 
print("\n\nINICIA foreach\n\n");
foreach(@trial_spkr_utts){ 

	 my $current_spkr = $_; 

	 my $tens = int($ind/10); 

	 my $random_number_target; 

	 my $random_number_nontarget; 

	 my %random_numbers_used = ();

	 #print($current_spkr);
	 for (1..$number_trials){ 

	 	  

	 	 do{ 

	 	 	$random_number_target = int(rand(10)) + $tens*10;
	 	 	print("\ncs: $current_spkr\n");
	 		print("rnt: $random_number_target\n");

	 	 }while(exists $random_numbers_used{$random_number_target} || $random_number_target eq $ind || $random_number_target > 282); 

	 	  

	 	 $random_numbers_used{$random_number_target} = $random_number_target; 

	 	 print TRIAL_OUT "$current_spkr", " $trial_spkr_utts[$random_number_target]", " target", "\n";

	 	 do{ 

	 	 	$random_number_nontarget = int(rand($n_test_spkrs)); 
	 	 	 #print("hola 2");
	 	 	print("$n_test_spkrs");
	 	 	print("\nrnt: $random_number_target\n");
	 	 	print("rnu-rnt: $random_numbers_used{$random_number_target}\n");
	 	 	print("cs: $current_spkr\n");
			print("rnnt: $random_number_nontarget\n");
			print("tens: $tens\n");
	 	 }while(exists $random_numbers_used{$random_number_nontarget} || int($random_number_nontarget/10) == $tens); 

	 	 $random_numbers_used{$random_number_nontarget} = $random_number_nontarget; 
	 	 #print("\nrnnt$random_numbers_used{$random_number_nontarget}\n");
	 	 print TRIAL_OUT "$current_spkr", " $trial_spkr_utts[$random_number_nontarget]", " nontarget", "\n"; 

	 	  

	 	  

	 } 

	  

	 $ind++; 

} 

 
 print("\n\nExit program\n\n");

close(TRIAL_OUT) or die; 