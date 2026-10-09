function results = run_tests()
%RUN_TESTS Run the AnestheSIM test suite (no internet connection needed).

setup_anesthesim;
import matlab.unittest.TestRunner
import matlab.unittest.TestSuite

suite = TestSuite.fromFolder(fullfile(anesthesimRoot(), 'tests'));
runner = TestRunner.withTextOutput;
results = runner.run(suite);
disp(table(results));
assertSuccess(results);
if nargout == 0
    clear results
end
end
