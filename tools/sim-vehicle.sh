set -e 

LCDDIR=../src/display/KT-LCD3
LCDIN=/tmp/lcdin.fifo
LCDOUT=/tmp/lcdout.fifo
LCDLOG=lcdout.log
LCDPORT=9001

MCDIR=../src/controller
MCIN=/tmp/mcin.fifo
MCOUT=/tmp/mcout.fifo
MCLOG=mcout.log
#MCOUT=mcout.log
MCPORT=9000

# Make sure binaries are up to date
pushd ../src/controller
make -f Makefile_linux
popd

pushd ../src/display/KT-LCD3
make -f Makefile_linux
popd

rm -f $LCDOUT $MCOUT $MCIN $LCDIN
mkfifo $LCDOUT $MCOUT $MCIN $LCDIN

# kill all our child processes if we get killed
trap 'kill $(jobs -p)' EXIT

# use pipes to connect the two simulators per http://mazsola.iit.uni-miskolc.hu/~drdani/embedded/ucsim/serial.html
# but log the sent packets to a file for debugging

tee $LCDLOG >$MCIN <$LCDOUT &
tee $MCLOG >$LCDIN <$MCOUT &

sleep 1 

echo "Running MC simulator, command console on port $MCPORT"
sstm8 -g -w -tSTM8S105 -Suart=2,in=$MCIN,out=$MCOUT -I -p "mc: " -Z$MCPORT -C $MCDIR/sim-setup.cmds $MCDIR/main.hex &

sleep 1 

echo "Running LCD simulator, command console on port $LCDPORT"
sstm8 -g -w -tSTM8S105 -Suart=2,out=$LCDOUT,in=$LCDIN -I -p "lcd3: " -Z$LCDPORT -C $LCDDIR/sim-setup.cmds $LCDDIR/main.hex &

# prime the pumps on the fifos so that both processes can be unblocked
# echo >>$LCDOUT 

RUNTIME=30000
echo "Simulators are running for $RUNTIME seconds, press ctrl-C to stop them"
sleep $RUNTIME

