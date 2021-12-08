#include <otawa/otawa.h>
#include <otawa/ipet.h>

using namespace elm;
using namespace otawa;

class TimeBuilder: public BBProcessor {
public:
	static p::declare reg;
	TimeBuilder(): BBProcessor(reg) { }

protected:

	void processBB(WorkSpace *ws, CFG *cfg, Block *b) override {
		if(!b->isBasic())
			return;
		BasicBlock *bb = b->toBasic();
		int somme_totale = 0;
		for(auto i : *bb){
			if(i->isMul()){
				somme_totale += 4;
			}
			else if(i-> isLoad()){
				somme_totale += 5;
			}
			else if(i->isStore()){
				somme_totale += 2;
			}
			else if(i->isControl()){
				somme_totale += 2;
			}
			else if(i->isConditional()){
				somme_totale += 2;
			}
			else{
				somme_totale += 1;
			}
		}
		ipet::TIME(b) = somme_totale;
		cout  << "time = " << *ipet::TIME(b) << io::endl;
	}

};

p::declare TimeBuilder::reg = p::init("TimeBuilder", Version(1, 0, 0))
	.require(COLLECTED_CFG_FEATURE)
	.provide(ipet::BB_TIME_FEATURE);


class FlashAnalysis: public CFGProcessor {
public:
	static p::declare reg;
	FlashAnalysis(): CFGProcessor(reg) { }

protected:

	void processAll(WorkSpace *ws) override {
		Vector<Block *> todo;

	}

	void processCFG(WorkSpace *ws, CFG *g) override {
	}

private:

	Address join(Address a1, Address a2) {
		if( (a1.offset() == a2.offset())  || a2.offset() == BOT.offset() ){
			return a1;
		}
		else if(a1.offset() == BOT.offset() ){
			return a2;
		}
		else{
			return TOP;
		}
	}

	Address update(Address s, Inst *i) {
	}

	Address input(Block *v) {

	}

	Address flashBlock(Inst *i) {
		return i->address().mask(mask);
	}

	static p::id<Address> OUT;
	static const Address TOP, BOT;
	static const t::uint32 mask = 32 - 1;
	static const ot::time cost = 10;
};

p::declare FlashAnalysis::reg = p::init("FlashAnalysis", Version(1, 0, 0))
	.require(COLLECTED_CFG_FEATURE)
	.require(ipet::BB_TIME_FEATURE);

p::id<Address> FlashAnalysis::OUT("", BOT);
const Address FlashAnalysis::TOP(-1, -2);
const Address FlashAnalysis::BOT;


int main(int argc, char **argv) {

	// check if we have exactly one parameter!
	if(argc != 2) {
		cerr << "SYNTAX: " << argv[0] << " ELF_FILE\n";
		return 1;
	}

	try {

		// this proplist is used to pass option for ELF file opening
		PropList props;

		// comment this to avoid verbose display of OTAWA
		VERBOSE(props) = true;

		// open the binary file and store it in a workspace
		WorkSpace *ws = MANAGER.load(argv[1], props);

		// compute the time of blocks and store it using ipet::TIME property
		ws->run<TimeBuilder>(props);

		// flash analysis
		ws->run<FlashAnalysis>(props);

		// compute WCET
		ws->require(ipet::WCET_FEATURE, props);

		// display the WCET that has been stored on the workspace using ipet::WCET property
		cout << "WCET = " << *ipet::WCET(ws) << io::endl;

	}
	catch(elm::Exception& e) {
		cerr << "ERROR: " << e.message() << io::endl;
		return 2;
	}

	return 0;
}
