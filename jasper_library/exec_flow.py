#! /usr/bin/env python

import os
import logging
import toolflow
import time

# A straight lift from StackOverflow...
def shell_source(script):
    """Sometime you want to emulate the action of "source" in bash,
    settings some environment variables. Here is a way to do it."""
    import subprocess, os
    pipe = subprocess.Popen(". %s > /dev/null; env" % script, stdout=subprocess.PIPE, shell=True)
    output = pipe.communicate()[0]
    env = dict((line.split("=", 1) for line in output.splitlines()))
    os.environ.update(env)


from optparse import OptionParser
parser = OptionParser()
parser.add_option("--perfile", dest="perfile", action='store_true', default=False,
                  help="Run Frontend peripheral file generation")
parser.add_option("--frontend", dest="frontend", action='store_true', default=False,
                  help="Run Frontend IP compile")
parser.add_option("--middleware", dest="middleware", action='store_true', default=False,
                  help="Run Toolflow middle")
parser.add_option("--backend", dest="backend", action='store_true', default=False,
                  help="Run backend compilation")
parser.add_option("--software", dest="software", action='store_true', default=False,
                  help="Run software compilation")
parser.add_option("--be", dest="be", type='string', default='vivado',
                  help="Backend to use. Default: vivado")
parser.add_option("--jobs", dest="jobs", type='int', default=4,
                  help="Number of cores to run compiles with. Default=4")
parser.add_option("--nonprojectmode", dest="nonprojectmode", action='store_false', default=True,
                  help="Project Mode is enabled by default/Non Project Mode is disabled by Default (NB: Vivado Only)")
parser.add_option("-m", "--model", dest="model", type='string',
                  default='/tools/mlib_devel/jasper_library/test_models/test.slx',
                  help="model to compile")
parser.add_option("-c", "--builddir", dest="builddir", type='string',
                  default='',
                  help="build directory. Default: Use directory with same name as model")

(opts, args) = parser.parse_args()

# get build directory
# use user defined directory else use a directory with same name as model
builddir = opts.builddir or opts.model[:-4]

# logging stuff...
os.system('mkdir -p %s'%builddir)
logger = logging.getLogger('jasper')
logger.setLevel(logging.DEBUG)

handler = logging.FileHandler('%s/jasper.log'%builddir, mode='w')
handler.setLevel(logging.DEBUG)
format = logging.Formatter('%(levelname)s - %(asctime)s - %(name)s - %(message)s')
handler.setFormatter(format)

logger.addHandler(handler)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

logger.info('Starting compile')

if opts.be == 'vivado':
    os.environ['SYSGEN_SCRIPT'] = os.environ['MLIB_DEVEL_PATH']+'/startsg'
if opts.be == 'ise':
    os.environ['SYSGEN_SCRIPT'] = os.environ['MLIB_DEVEL_PATH']+'/startsg_ise'

# initialise the toolflow
tf = toolflow.Toolflow(frontend='simulink', compile_dir=builddir, frontend_target=opts.model, jobs=opts.jobs)

if opts.perfile:
    tf.frontend.gen_periph_file(tf.periph_file)

if opts.middleware:
    tf.gen_periph_objs()
    tf.build_top()
    tf.generate_hdl()
    tf.generate_consts()
    tf.write_core_info()
    tf.constraints_rule_check()
    tf.dump_castro(tf.compile_dir+'/castro.yml')

if opts.frontend:
    tf.frontend.compile_user_ip(update=True)

#Project Mode assignment (True = Project Mode, False = Non-Project Mode)
projectmode = opts.nonprojectmode


if opts.backend or opts.software:
    try:
        platform = tf.plat
    except AttributeError:
        platform = None

    if platform.backend_target == 'vivado':
        backend = toolflow.VivadoBackend(plat=platform, prjmode=projectmode, compile_dir=tf.compile_dir)
    else:
        backend = IseBackend(platform=platform, compile_dir=tf.compile_dir)

if opts.backend:
    backend.import_from_castro(backend.compile_dir+'/castro.yml', prjmode=projectmode)
    # launch vivado via the generated .tcl file
    backend.compile(cores=opts.jobs, prjmode=projectmode, plat=platform)

    backend.output = tf.frontend_target_base[:-4] + '_%d-%d-%d_%.2d%.2d.bof'%(tf.start_time.tm_year, tf.start_time.tm_mon, tf.start_time.tm_mday,
            tf.start_time.tm_hour, tf.start_time.tm_min)

if opts.software:
    binary = backend.binary_loc
    os.system('cp %s %s/top.bin'%(binary, backend.compile_dir))
    mkbof_cmd = '%s/jasper_library/mkbof_64 -o %s/%s -s %s/core_info.tab -t 3 %s/top.bin'%(os.getenv('MLIB_DEVEL_PATH'), backend.output_dir, backend.output, backend.compile_dir, backend.compile_dir)
    os.system(mkbof_cmd)
