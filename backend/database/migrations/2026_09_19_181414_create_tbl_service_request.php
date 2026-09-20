<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_serviceRequest', function (Blueprint $table) {
            $table->bigIncrements('v_serviceRequestId');

            $table->string('v_serviceRequestNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_customerId');

            $table->unsignedBigInteger('v_serviceId')
                ->nullable();

            $table->dateTime('v_requestDate')
                ->useCurrent();

            $table->string('v_projectName', 150)
                ->nullable();

            $table->string('v_projectType', 100)
                ->nullable();

            $table->string('v_buildingStructureType', 100)
                ->nullable();

            $table->string('v_projectLocation', 255)
                ->nullable();

            $table->text('v_projectRequirements')
                ->nullable();

            $table->text('v_customerConcerns')
                ->nullable();

            $table->dateTime('v_preferredSchedule')
                ->nullable();

            $table->string('v_requestStatus', 50)
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign('v_customerId', 'fk_serviceRequest_customer')
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign('v_serviceId', 'fk_serviceRequest_service')
                ->references('v_serviceId')
                ->on('tbl_service')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_serviceRequest');
    }
};