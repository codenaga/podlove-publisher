<?php

namespace Podlove;

use PodlovePublisher_Vendor\Monolog\Handler\ErrorLogHandler;
use PodlovePublisher_Vendor\Monolog\Logger;

/**
 * Podlove Logger class.
 *
 * @see  https://github.com/Seldaek/monolog for documentation
 *
 * When to use what kind of log message?
 * - DEBUG: Detailed debug information.
 * - INFO: Interesting events. Examples: User logs in, SQL logs.
 * - WARNING: Exceptional occurrences that are not errors. Examples: Use of deprecated APIs, poor use of an API, undesirable things that are not necessarily wrong.
 * - ERROR: Runtime errors that do not require immediate action but should typically be logged and monitored.
 * - CRITICAL: Critical conditions. Example: Application component unavailable, unexpected exception.
 * - ALERT: Action must be taken immediately. Example: Entire website down, database unavailable, etc. This should trigger the SMS alerts and wake you up.
 *
 * Example usage:
 *   use Podlove\Log;
 *
 *   Log::get()->addWarning( 'This is a warning.' );
 *   Log::get()->addWarning( 'This is another warning.', array( 'comment' => 'additional info' ) );
 */
class Log
{
    private static $instance;
    private $log;

    private function __construct()
    {
        $log = new Logger('Podlove');
        if ($this->is_debug_enabled()) {
            $log->pushHandler(new ErrorLogHandler(ErrorLogHandler::OPERATING_SYSTEM, $this->get_log_level()));
        }

        $this->log = $log;
    }

    /**
     * Proxy calls to Logger instance.
     *
     * @param string $name      method name
     * @param array  $arguments
     */
    public function __call($name, $arguments)
    {
        // proxy deprecated monolog function names
        // TODO: replace all add* calls in code
        if ($name == 'addWarning') {
            $name = 'warning';
        }
        if ($name == 'addInfo') {
            $name = 'info';
        }
        if ($name == 'addError') {
            $name = 'error';
        }
        if ($name == 'addDebug') {
            $name = 'debug';
        }

        if (method_exists($this->log, $name)) {
            call_user_func_array([$this->log, $name], $arguments);
        }
    }

    public function __clone()
    {
        trigger_error('Singleton. Cloning not allowed.', E_USER_ERROR);
    }

    public function __wakeup()
    {
        trigger_error('Singleton. Deserialisation not allowed.', E_USER_ERROR);
    }

    public static function get()
    {
        if (!isset(self::$instance)) {
            self::$instance = new self();
        }

        return self::$instance;
    }

    public function get_log_level()
    {
        if (defined('PODLOVE_LOG_LEVEL')) {
            return constant('PODLOVE_LOG_LEVEL');
        }

        return $this->is_debug_enabled() ? Logger::DEBUG : Logger::INFO;
    }

    public function is_debug_enabled()
    {
        return defined('PODLOVE_LOGGER_DEBUG') && constant('PODLOVE_LOGGER_DEBUG');
    }
}
