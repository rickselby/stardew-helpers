<?php

namespace App\Console\Commands;

use App\Services\Locations;
use Illuminate\Console\Command;

class BuildLocationFile extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'locations:build';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Build the locations file';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle(Locations $locations)
    {
        $locations->buildFile();
        $this->info('File generated successfully.');
    }
}
