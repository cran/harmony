

struct TimerMeta{
  double elapsed = 0;
  double last = 0;
  unsigned iter = 0;
};


using namespace std::chrono;
typedef high_resolution_clock::time_point Timepoint;
class Timer;


class Timer{
 public:
  Timepoint start;
  std::string task_name;
  double& timer;

};
