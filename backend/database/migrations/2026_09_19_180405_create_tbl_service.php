<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_service', function (Blueprint $table) {
            $table->bigIncrements('v_serviceId');

            $table->string('v_serviceCode', 60)
                ->nullable()
                ->unique();

            $table->string('v_serviceName', 150);

            $table->string('v_serviceCategory', 100)
                ->nullable();

            $table->text('v_serviceDescription')
                ->nullable();

            $table->decimal('v_basePrice', 14, 2)
                ->nullable();

            $table->boolean('v_isActive')
                ->default(true);

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_service');
    }
};