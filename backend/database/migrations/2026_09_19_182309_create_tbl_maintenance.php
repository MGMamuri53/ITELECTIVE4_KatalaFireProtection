<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_maintenance', function (Blueprint $table) {
            $table->bigIncrements('v_maintenanceId');

            $table->string('v_maintenanceNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_customerId');

            $table->unsignedBigInteger('v_projectId')
                ->nullable();

            $table->unsignedBigInteger('v_warrantyId')
                ->nullable();

            $table->unsignedBigInteger('v_serviceId')
                ->nullable();

            $table->string('v_maintenanceType', 100)
                ->nullable();

            $table->text('v_equipmentSystemDescription')
                ->nullable();

            $table->string('v_location', 255)
                ->nullable();

            $table->dateTime('v_scheduledDate')
                ->nullable();

            $table->dateTime('v_completedDate')
                ->nullable();

            $table->string('v_maintenanceStatus', 50)
                ->nullable();

            $table->text('v_findings')
                ->nullable();

            $table->text('v_actionsPerformed')
                ->nullable();

            $table->text('v_recommendations')
                ->nullable();

            $table->dateTime('v_nextMaintenanceDate')
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_customerId',
                'fk_maintenance_customer'
            )
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_projectId',
                'fk_maintenance_project'
            )
                ->references('v_projectId')
                ->on('tbl_project')
                ->onUpdate('cascade')
                ->onDelete('set null');

            $table->foreign(
                'v_warrantyId',
                'fk_maintenance_warranty'
            )
                ->references('v_warrantyId')
                ->on('tbl_warranty')
                ->onUpdate('cascade')
                ->onDelete('set null');

            $table->foreign(
                'v_serviceId',
                'fk_maintenance_service'
            )
                ->references('v_serviceId')
                ->on('tbl_service')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_maintenance');
    }
};