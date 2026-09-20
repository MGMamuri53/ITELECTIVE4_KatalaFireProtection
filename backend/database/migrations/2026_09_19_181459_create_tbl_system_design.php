<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_systemDesign', function (Blueprint $table) {
            $table->bigIncrements('v_systemDesignId');

            $table->unsignedBigInteger('v_serviceRequestId');

            $table->string('v_designTitle', 150)
                ->nullable();

            $table->text('v_designDescription')
                ->nullable();

            $table->string('v_designFileReference', 255)
                ->nullable();

            $table->string('v_designVersion', 50)
                ->nullable();

            $table->dateTime('v_preparedDate')
                ->nullable();

            $table->dateTime('v_presentedDate')
                ->nullable();

            $table->string('v_approvalStatus', 50)
                ->nullable();

            $table->dateTime('v_approvalDate')
                ->nullable();

            $table->text('v_customerRemarks')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_serviceRequestId',
                'fk_systemDesign_serviceRequest'
            )
                ->references('v_serviceRequestId')
                ->on('tbl_serviceRequest')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_systemDesign');
    }
};