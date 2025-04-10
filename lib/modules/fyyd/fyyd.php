<?php

namespace Podlove\Modules\fyyd;

class fyyd extends \Podlove\Modules\Base
{
    protected $module_name = 'fyyd';
    protected $module_description = 'Inserts a verification code into your feeds for the fyyd search engine.';
    protected $module_group = 'Podcast Directories';

    public function load()
    {
        add_action('init', [$this, 'register_hooks']);
        add_action('init', [$this, 'register_module_option']);
    }

    public function register_hooks()
    {
        $fyyd_verifycode = $this->get_module_option('fyyd_verifycode');
        if (!$fyyd_verifycode) {
            return;
        }
        add_action('podlove_rss2_head', function ($feed) use ($fyyd_verifycode) {
            echo "\n\t".sprintf('<fyyd:verify xmlns:fyyd="https://fyyd.de/fyyd-ns/">%s</fyyd:verify>'."\n\t", $fyyd_verifycode);
        });
    }

    public function register_module_option()
    {
        $this->register_option('fyyd_verifycode', 'string', [
            'label' => __('fyyd verifycode', 'podlove-podcasting-plugin-for-wordpress'),
            'description' => __('Code to verify your ownership at fyyd', 'podlove-podcasting-plugin-for-wordpress'),
            'html' => [
                'class' => 'regular-text podlove-check-input',
                'data-podlove-input-type' => 'text',
                'placeholder' => 'yourverifycodehere',
            ],
        ]);
    }
}
